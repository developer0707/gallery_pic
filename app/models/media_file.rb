require 'securerandom'
require 'streamio-ffmpeg'

class MediaFile < ParseActiveRecord
  belongs_to :user
  validates_presence_of :name

  def self.save_path(params = {})
  	random = SecureRandom.uuid
  	params[:dir] = "0" unless params[:dir]

  	dir_path = 'public/files/' + params[:dir]

    FileUtils.mkdir_p(dir_path) unless File.exists?(dir_path)
  	name = dir_path + '/' + random
  	if params[:ext]
  		params[:ext] = "." + params[:ext] unless params[:ext].starts_with?(".")
		name = name + params[:ext].downcase
  	end
  	name
  end

  def self.public_path(saved_path)
  	if saved_path.starts_with? "public/"
  		saved_path.sub(/public/, '')
  	else
  		saved_path
  	end
  end

  #returns expected extension for file after conversion
  def self.ext(path)
    mime = %x[file --mime-type #{path}].split(":")[1].strip
    if mime.starts_with? "image/"
      "jpg"
    elsif mime.starts_with? "video/"
      "mp4"
    else
      File.extname(path)
    end
  end

  def build_url(request)
  	self.url ? request.base_url + self.url : self.parse_url
  end

  def convert_file(old_path)
    mime = %x[file --mime-type #{old_path}].split(":")[1].strip

    message = "Converting mime:" + mime + " at: "  + old_path

    puts message

    if mime.starts_with? "image/"
      image = MiniMagick::Image.open(old_path)
      orientation = image.exif[:Orientation]

      if orientation.eql? "6"
        image.rotate(90)
      elsif orientation.eql? "3"
        image.rotate(180)
      elsif orientation.eql? "8"
        image.rotate(270)
      end
      image.format "JPG"
      final_path = "public" + self.url
      image.write(final_path)
    elsif mime.starts_with? "video/"
      convert_video(old_path)
    else
      #shouldn't get here
      return
    end
  end

  def convert_video(old_path)
    mime = %x[file --mime-type #{old_path}].split(":")[1].strip

    message = "Converting mime:" + mime + " at: "  + old_path

    delayed_log message

    if mime.starts_with? "image/"
      image = MiniMagick::Image.open(old_path)
      orientation = image.exif[:Orientation]

      if orientation == "6"
        image.rotate(90)
      elsif orientation == "3"
        image.rotate(180)
      elsif orientation == "8"
        image.rotate(270)
      end
      image.format "JPG"
      final_path = "public" + self.url
      image.write(final_path)
    elsif mime.starts_with? "video/"
      ext = mime.split("/")[1]
      ext = 'mp4'
      FFMPEG.ffmpeg_binary = "~/bin/ffmpeg"
      movie = FFMPEG::Movie.new(old_path)
      log_movie("original", movie)
      final_path = "public" + self.url

      bitrate = max_bitrate(movie)

      options = " -c:v libx264 -crf 17 -maxrate " + bitrate + " -bufsize " + bitrate + " -profile:v baseline"
      movie = movie.transcode(final_path, options)

      log_movie("output", movie)
    else
      #shouldn't get here
      return
    end
  end

  handle_asynchronously :convert_video

  def log_movie(tag, movie)
    tags = {}

    tags[:valid] = movie.valid?
    tags[:duration] = movie.duration # 7.5 (duration of the movie in seconds)
    tags[:bitrate] = movie.bitrate # 481 (bitrate in kb/s)
    tags[:size] = movie.size # 455546 (filesize in bytes)
    tags[:rotation] = movie.rotation

    tags[:video_stream] = movie.video_stream # "h264, yuv420p, 640x480 [PAR 1:1 DAR 4:3], 371 kb/s, 16.75 fps, 15 tbr, 600 tbn, 1200 tbc" (raw video stream info)
    tags[:video_codec] = movie.video_codec # "h264"
    tags[:colorspace] = movie.colorspace # "yuv420p"
    tags[:resolution] = movie.resolution # "640x480"
    tags[:width] = movie.width # 640 (width of the movie in pixels)
    tags[:height] = movie.height # 480 (height of the movie in pixels)
    tags[:frame_rate] = movie.frame_rate # 16.72 (frames per second)

    tags[:audio_stream] = movie.audio_stream # "aac, 44100 Hz, stereo, s16, 75 kb/s" (raw audio stream info)
    tags[:audio_codec] = movie.audio_codec # "aac"
    tags[:audio_sample_rate] = movie.audio_sample_rate # 44100
    tags[:audio_channels] = movie.audio_channels # 2

    message = tag + ": " + tags.to_json
    delayed_log message
  end

  def max_bitrate(movie)
    #getting video quality (240p, 360p, 480p... 1080p)
    quality = movie.height

    if quality >= 240 && quality < 360
      "350k"
    elsif quality >= 360 && quality < 480
      "768k"
    else#if quality >= 480 && quality < 720 #for now we support maximum 480p
      "1500k"
    # elsif quality >= 720 && quality < 1080
      # "2500k"
    # else
    #   #anything more than 1080 should be treated the same for now
    #   "5000k"
    end
  end

  def delayed_log(message)
    time = DateTime.now.to_s
    full_message = time + ": " + message
    system("echo '#{full_message}' >> delayed_jobs.log")
  end

end

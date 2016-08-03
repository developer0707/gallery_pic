require 'securerandom'
require 'streamio-ffmpeg'
require 'delayed_job'

class MediaFilesController < UserActionController

  def create
  	file = params[:data]

  	if !file
  		output_error(401, "Missing file parameter")
  		return
  	end

    mime = %x[file --mime-type #{file.path}].split(":")[1].strip

    puts "File received " + mime + " size: " + file.size.to_s

    if !mime.starts_with?("image/") && !mime.starts_with?("video/")
      output_error(401, "Unsupported file type")
      return
    end
    
    ext = MediaFile.ext(file.path)
    path = MediaFile.save_path(ext: ext)

  	mediaFile = MediaFile.new
  	mediaFile.url = MediaFile.public_path(path)
    mediaFile.name = File.basename(path)
  	mediaFile.save

    mediaFile.convert_file(file.path)

  	output (mediaFile)
  end

  def show
  	mediaFile = MediaFile.find(params[:id])
  	send_file (mediaFile.url)
  end

end
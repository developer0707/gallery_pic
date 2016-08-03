require 'securerandom'

class ParseActiveRecord < ActiveRecord::Base
  self.abstract_class = true
  before_save :set_default_values

  def merge_from_parse_json(object_json)
  	self.parse_object_id = object_json["objectId"]
    self.created_at = object_json["createdAt"]
    self.updated_at = object_json["updatedAt"]
  end

  def set_default_values
    return true
  end

  def import_parse_file(parse_file)
    if parse_file
      file_name = parse_file["name"]
      # random = SecureRandom.uuid
      # path = "public/files/0/" + random + "_" + file_name
      # FileUtils.mkdir_p(File.dirname(path)) unless File.exists?(File.dirname(path))

      # IO.copy_stream(open(parse_file["url"]), path)
      # File.open(path, "w+") {|f| f.write(File.read(parse_file["url"])) }
      file = MediaFile.new
      # file.url = path
      file.parse_url = parse_file["url"]
      file.name = file_name
      file.save
      return file
    end
  end

  def resize_and_crop(image, size)
   if image[:width] < image[:height]
   shave_off = ((
   image[:height]-
   image[:width])/2).round
   image.shave("0x#{shave_off}")
   elsif image[:width] > image[:height]
   shave_off = ((
   image[:width]-
   image[:height])/2).round
   image.shave("#{shave_off}x0")
   end
   image.resize("#{size}x#{size}")
   return image
  end

  def thumbnail_from_file(mediaFile, user_id)
    if mediaFile == 0 || !mediaFile
      return false
    end
    mediaFile = MediaFile.find(mediaFile)
    if !mediaFile
      return false
    end

    image = nil;

    if mediaFile.url
      image = MiniMagick::Image.open("public/" + mediaFile.url)
    # elsif mediaFile.parse_url
    #   image = MiniMagick::Image.open(mediaFile.parse_url)
    else
      return false
    end
    
    random = SecureRandom.uuid
    thumbnailPath = "/files/0/" + random + "_" + mediaFile.name + "_thumbnail" + File.extname(mediaFile.name)
    thumbnail = resize_and_crop(image, 240)
    thumbnail.write("public" + thumbnailPath)
    thumbnailFile = MediaFile.new
    thumbnailFile.url = thumbnailPath
    thumbnailFile.name = File.basename(thumbnailPath)
    thumbnailFile.save

    return thumbnailFile
  end

end
require 'securerandom'
require 'zip'
require 'net/http'

class ImportsController < ApplicationController
  before_action :validate_secret_token
  protect_from_forgery :except => [:parse_insert_object, :parse_delete_object]
  skip_before_action :validate_secret_token, only: [:parse_insert_object, :parse_delete_object]
  skip_before_action :validate_api_key

  def validate_secret_token
    if params[:secret_token] != '65eb2a63e0990015dcc7995de227fbca'
      render_json({ :well => "well"})
    end
  end

  def upload
    file = params[:xml_file]
    write_file_content_to_path("app/assets/json/data.zip", File.read(file.tempfile.path)) unless !file
  end

  def all
    class_names = all_classes

    unzip_data

    0.upto(class_names.count - 1) do |i|
      parse_class_name = class_names[i]
      class_name = parse_class_name
      if class_name.starts_with?('_')
        class_name = parse_class_name.delete "_"
      elsif parse_class_name == 'PhotoPost'
        class_name = "Post"
      end
      if !read_json(parse_class_name, class_name)
        return
      end
    end

    output get_response_data({})
  end

  def all_classes
    return [
      "Category", 
      "Country", 
      "State", 
      "City", 
      "Place", 
      "_User",
      "_Installation",
      "PhotoPost",
      "Comment",
      "Round",
      "Action",
      "TextMention"
    ]
  end

  def categories
    unzip_data
    if !read_json("Category", "Category")
        return
    end

    render_json(Category.all.as_json)
  end

  def countries
    unzip_data
    if !read_json("Country", "Country")
        return
    end

    render_json(Country.all.as_json)
  end

  def states
    unzip_data
    if !read_json("State", "State")
        return
    end

    render_json({})
  end

  def cities
    unzip_data
    if !read_json("City", "City")
        return
    end

    render_json({})
  end

  def places
    unzip_data
    if !read_json("Place", "Place")
        return
    end

    render_json({})
  end

  def users
    unzip_data
    if !read_json("_User", "User")
        return
    end

    render_json({})
  end

  def installations
    unzip_data
    if !read_json("_Installation", "Installation")
        return
    end

    render_json({})
  end

  def posts
    unzip_data
    if !read_json("PhotoPost", "Post")
        return
    end

    render_json({})
  end

  def comments
    unzip_data
    if !read_json("Comment", "Comment")
        return
    end

    render_json({})
  end

  def rounds
    unzip_data
    if !read_json("Round", "Round")
        return
    end

    render_json({})
  end

  def actions
    unzip_data
    if !read_json("Action", "Action")
        return
    end

    render_json({})
  end

  def text_mentions
    unzip_data
    if !read_json("TextMention", "TextMention")
      return
    end

    render_json({})
  end

  def unzip_data
    @files = {}
    zip_path = 'app/assets/json/data.zip'
    Net::HTTP.start("env-piccmee.whelastic.net") do |http|
      f = open(zip_path, "wb")
      begin
          http.request_get('/data.zip') do |resp|
              resp.read_body do |segment|
                  f.write(segment)
              end
          end
      ensure
          f.close()
      end
    end

    Zip::File.open(zip_path) do |zipfile|
      zipfile.each do |file|
        path = "app/assets/json/" + file.name
        file.extract(path) unless File.exist?(path)
        @files[file.name] = path
      end
    end
  end

  def read_json(file_name, class_name)
    file_name_no_ext = file_name
    file_name = file_name + ".json"

    content = get_file_content(file_name)
    if !content
      return true
    end

    results = content["results"]
    puts "Results count " + results.count.to_s + " for class " + class_name

    if results.count == 0

    else
      create_files_for_json(results, class_name, file_name_no_ext)
    end

    content_to_write = { "results" => [] }
    write_file_content(file_name, JSON.pretty_generate(content_to_write))

    import_json_from_directory(file_name_no_ext, class_name)

    return true
  end

  def create_files_for_json(json, class_name, file_name)
    while json.count > 0
      json_copy = json.slice!(0, 1000)

      random = SecureRandom.uuid
      file_path = "app/assets/json/" + file_name
      FileUtils.mkdir_p(file_path) unless File.exists?(file_path)
      file_path = file_path + "/" + random + ".json"
      content_to_write = { "results" => json_copy }
      write_file_content_to_path(file_path, JSON.pretty_generate(content_to_write))
    end
  end

  def import_json_from_directory(file_name, class_name)
    file_path = "app/assets/json/" + file_name
    file_index = 0
    Dir.foreach(file_path) do |file|
      if File.extname(file) == '.json'
        import_json_from_file_path(file_path + "/" + file, class_name)
      end
      file_index = file_index + 1
      puts 'File index ' + file_index.to_s + " for " + class_name
    end
  end

  def import_json_from_file_path(file_path, class_name)
    renamed_path = file_path + ".lock"
    content = get_file_content_from_path(file_path)
    done = true
    if content
      File.rename(file_path, renamed_path)

      results = content["results"]

      results_copy = results
      
      index = 0
      results.each do |object_json|
        object = find_or_create(class_name, object_json)
        saved = object.save
        index = index + 1
        if saved
          results_copy = results_copy - [object_json]

          if index % 100 == 0
            puts class_name + ": Index = " + index.to_s + " / " + results.count.to_s
            content_to_write = { "results" => results_copy }
            write_file_content_to_path(renamed_path, JSON.pretty_generate(content_to_write))
          end
        else
          puts "Error with " + class_name + " " + object.to_json.to_s + " errors: " + object.errors.messages.flatten(2).to_s + " json " + object_json.to_s
        end
      end

      File.rename(renamed_path, file_path)
    end

    File.delete(file_path) unless results_copy.count > 0
    return done
  end

  def get_file_content(file_name)
    return get_file_content_from_path(@files[file_name])
  end

  def get_file_content_from_path(file_path)
    data = File.read(file_path)
    begin
      return JSON(data)
    rescue JSON::ParserError 
      raise "JSON::ParserError : data = " + data + " for file: " + file_path
    end
  end

  def write_file_content(file_name, data)
    write_file_content_to_path(@files[file_name], data)
  end

  def write_file_content_to_path(file_path, data)
    File.open(file_path, "w+") {|f| f.write(data) }
  end

  def find_or_create(class_name, object_json)
    object = Object.const_get(class_name).unscoped.find_or_create_by(parse_object_id: object_json["objectId"])
    object.merge_from_parse_json(object_json)
    return object
  end

  def parse_insert_object
    if request.headers['X-Parse-Webhook-Key'] != '6McymBQnaVzd9qTw4SmGZmj6lKWTIGO0FYawjSPt' 
      render_json ({ :error => "Request Unauthorized"} )
      return
    end

    parse_class_name = params["className"]
    class_name = parse_class_name
    if class_name.starts_with?('_')
      class_name = parse_class_name.delete "_"
    elsif parse_class_name == 'PhotoPost'
      class_name = "Post"
    end
    object_json = params["object"]
    object = find_or_create(class_name, object_json)
    saved = object.save
    if saved
      render_json({:success => true})
    else
      render_json({:error => "Error with " + object.to_json.to_s + " errors: " + object.errors.messages.flatten(2).to_s + " json " + object_json.to_s})
    end
  end

  def parse_delete_object
    if request.headers['X-Parse-Webhook-Key'] != '6McymBQnaVzd9qTw4SmGZmj6lKWTIGO0FYawjSPt' 
      render_json ({ :error => "Request Unauthorized"} )
      return
    end

    parse_class_name = params["className"]
    class_name = parse_class_name
    if class_name.starts_with?('_')
      class_name = parse_class_name.delete "_"
    elsif parse_class_name == 'PhotoPost'
      class_name = "Post"
    end

    object_id = params["objectId"]

    object = Object.const_get(class_name).unscoped.find_by(parse_object_id: object_id)

    if object
      object.destroy
      render_json({:success => true})
    else
      render_json({:success => true, :result => "not deleted"})
    end
  end
end

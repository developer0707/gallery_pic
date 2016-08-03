require 'uri'

class Api::PhotosController < ActionController::Base
  protect_from_forgery with: :null_session
  respond_to :json, :xml, :html, :php

  def show
  	url = params[:url]
  	max_width = params[:maxWidth] ? params[:maxWidth].to_i : 0
  	if url == ''
    	render(:json => {})
    	return
  	end

	uri = URI(url)

	name = File.basename(url)

	final_url = load_image(name, max_width)

	if !final_url
		final_url = load_original(name)

		if !final_url
			final_url = download_image(url, url_for_image(name, 0))
		end

		if max_width > 0
			width = get_image_width(final_url)

			if max_width < width
				resized_file = url_for_image(name, max_width)

				final_url = resize_image(final_url, resized_file, max_width)
			end
		end
	end

	# touch final_url
  final_url.slice!("public/")
	redirect_to request.base_url + "/" + final_url
  end

  def url_for_image(name, max_width)
  	file_directory = 'public/files/' + max_width.to_s
    FileUtils.mkdir_p(file_directory) unless File.exists?(file_directory)

    return file_directory + "/" + name
  end

  def load_image(name, max_width)
  	cached_url = url_for_image(name, max_width)

  	return File.exists?(cached_url) ? cached_url : false
  end

  def load_original(name)
  	return load_image(name, 0)
  end

  def download_image(url, destination)
  	image = MiniMagick::Image.open(url)
  	image.write(destination)
    return destination
  end

  def get_image_width(url)
  	image = MiniMagick::Image.open(url)
  	return image.width
  end

  def resize_image(url, destination, size)
  	image = MiniMagick::Image.open(url)
  	width = image.width
  	height = image.height
  	new_height = (height * size) / width
    resize = size.to_s + 'x' + new_height.to_s
  	image.resize(resize)
  	image.write(destination)
  	return destination
  end

end
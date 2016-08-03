class Get::GetController < ActionController::Base
  protect_from_forgery with: :null_session
  respond_to :html
  rescue_from Exception, :with => :handle_exception

  	def show
		os = params[:os]

		@app_store = 'https://itunes.apple.com/us/app/piccmee/id1040170648?mt=8'
		@play_store = 'https://play.google.com/store/apps/details?id=com.piccmee.android'

		if os.eql? 'android'
			redirect_to @play_store
			return
		elsif os.eql? 'ios'
			redirect_to @app_store
			return
		end

		@url = params[:url]

		site_name = 'piccmee.com'
		fb_app_id = '827346304026899'
		title = 'PiccMee'
		description = nil
		image = nil

		if @url
			@uri = URI(@url)
			if @uri.scheme.eql? 'piccmee'
				path = @uri.path
				query = @uri.query.split("&").map {|param| param.split("=")}
				query = query.to_h
				id = query["id"]
				if path.eql?('/vote') || path.eql?('/post')
					post = Post.find(id)
					title = post.user.name
					description = post.caption
					image = post.photo.build_url(request)
				elsif path.eql? '/user'
					user = User.find(id)
					title = user.name
					description = user.bio
					if user.profile_picture
						image = user.profile_picture.build_url(request)
					end
				end
			end
		end

		if !description
			description = "PiccMee is app with a simple concept, Upload, Vote, Win!!! Users can upload pictures to several different categories, allow those pictures to be voted on, and at the end of each contest the users with the most votes in each category wins free cool prizes (Flat screen T.V's, Tablets, Smart Phones, and many more cool free prizes). Users can also be randomly picked to win these free prizes just by being social. For example, by posting the most the pictures, following the most people or inviting the most people to the app can get you randomly picked to win free prizes. We never ask for a credit card and you never pay for shipping and handling. This app is completely free and so are the prizes you win. Piccmee is a social app that gives back to the people and actually makes social media fun for people of all ages."
			image = '/icon175x175.jpeg'
		end

		@meta_tags = { "og:site_name" => site_name,
			"fb:app_id" => fb_app_id,
			"og:title" 	=> title,
			"og:description" => description,
			"og:image" => image,
			"og:url" => request.url
		}

		respond_with @meta_tags
	end
	
	def handle_exception(error)
	    puts request.method + ":" + request.url + " " + error.message
	    puts error.backtrace.to_s
	    output_error 500, "Internal Server Error"
  	end

  	def validate_secret_token
    	if params[:secret_token] != '65eb2a63e0990015dcc7995de227fbca'
      		render_json({ :well => "well"})
    	end
  	end

  	def render_json(data)
    	render(:json => data.to_json)
  	end

  	def output(value)
    	@data = value
    	respond_with(@data)
  	end

  	def output_error(code, message)
  		error = { 
  				"error" =>
  				{
		  			"code" => code,
		  			"message" => message 
		  		}
  			}

    	render_json(error)
  	end
end

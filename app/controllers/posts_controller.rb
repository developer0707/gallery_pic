class PostsController < UserActionController

	def explore
		posts = Post.unblocked(@session.user).order(created_at: :desc).limit(get_limit_default(24)).offset(get_offset)
		output (posts)
	end

	def category_posts
		round = Round.unscoped.active_round
		if !round
			output_error(301, "There's no active round.")
			return
		end
		posts = Post.unblocked(@session.user).where(['category_id = ? AND created_at > ? AND created_at < ?', params[:category_id], round.start_date, round.end_date]).order(votes_count: :desc).limit(get_limit_default(24)).offset(get_offset)
		output (posts)
	end

	def place_posts
		posts = Post.unblocked(@session.user).where(place_id: params[:place_id]).order(created_at: :desc).limit(get_limit_default(24)).offset(get_offset)
		output (posts)
	end

	def categories_search
		round = Round.unscoped.active_round
		if !round
			output_error(301, "There's no active round.")
			return
		end
		posts = Post.unblocked(@session.user).where("user_id IN (?) AND created_at > ? AND created_at < ?", User.search(params[:query]).select(:id), round.start_date, round.end_date).order(created_at: :desc).limit(get_limit).offset(get_offset)
		output(posts)
	end

	def user_posts
	    if params[:user_id] == "me"
	      params[:user_id] = @session.user.id
	    end
		posts = Post.unblocked(@session.user).where(user_id: params[:user_id]).order(created_at: :desc).limit(get_limit).offset(get_offset)
		output (posts)
	end

	def index
		posts = @session.user.news_posts.order(created_at: :desc).limit(get_limit).offset(get_offset)
		output (posts)
	end

	def create
		post = Post.new

		if params[:data][:caption]
			post.caption = params[:data][:caption]
		end

		photo_id = 0

		if params[:data][:photo_id]
			photo_id = params[:data][:photo_id].to_i
		elsif params[:data][:photo]
			photo_id = params[:data][:photo][:id]
		end

		if photo_id == 0
			output_error(401, "Missing photo or photo_id")
			return
		end

		if !validate_file(photo_id)
			return
		end

		post.photo_id = photo_id

		video_id = 0

		if params[:data][:video_id]
			video_id = params[:video_id].to_i
		elsif params[:data][:video]
			video_id = params[:data][:video][:id]
		end

		if video_id != 0
			if validate_file(video_id)
				post.video_id = video_id
			else
				return
			end
		end

		if params[:data][:place] && params[:data][:place][:latitude] && params[:data][:place][:longitude] && params[:data][:place][:google_place_id]
			params[:data][:place][:name] = params[:data][:place][:latitude].to_s + "," + params[:data][:place][:longitude] unless params[:data][:place][:name]
			place = Place.find_by(google_place_id: params[:data][:place][:google_place_id])
			place = Place.new unless place != nil
			place.attributes = params[:data][:place].permit([:name, :longitude, :latitude, :google_place_id])
			place.save
			post.place = place
		end

		if params[:data][:category_id]
			post.category_id = params[:data][:category_id].to_i
		elsif params[:data][:category] && params[:data][:category][:id]
			post.category_id = params[:data][:category][:id]
		end

		post.video_id = video_id
	    post.user_id = @session.user.id

	    if params[:data][:text_mentions]
	    	params[:data][:text_mentions].each do |text_mention|
	    		referenced_user_id  = 0
		        mention_start = text_mention[:mention_start]
		        mention_end = text_mention[:mention_end]
		        if text_mention[:referenced_user_id]
		          referenced_user_id = text_mention[:referenced_user_id]
		        elsif text_mention[:referenced_user][:id]
		          referenced_user_id = text_mention[:referenced_user][:id]
		        end
		        if referenced_user_id != 0
		          text_mention = TextMention.unscoped.new(user_id: @session.user.id, referenced_user_id:referenced_user_id, mention_start:mention_start, mention_end: mention_end)
		          post.text_mentions << text_mention
		        end
	    	end
	    end

	    if post.save
	    	#mentions actions
	      	if post.text_mentions && post.text_mentions.count > 0
		        mentioned_users = post.text_mentions.map {|text_mention| text_mention.referenced_user_id}
		        mentioned_users.uniq!

		        mentioned_users.each do |referenced_user_id|
		          action = Action.create(user_id: @session.user_id, action_type:10, referenced_object:post, referenced_user_id:referenced_user_id)
		          push_action action
		    	end
	      	end

        	puts 'Error saving counter for user ' + @session.user.errors.messages.flatten(2).to_s unless @session.user.increment!("posts_count")
	      	output (post)
	    else
	      output_error(302, "Failed to save post. " + post.to_json + " " + post.errors.messages.flatten(2).to_s)
	    end
	end

	def show
		post = Post.find(params[:id])
		output (post)
	end

	def like
    	flag = params[:flag] ? params[:flag] == '1' : true
		type = 1
		object = Post.find(params[:id])
		perform_action(flag, type, object, object.user)
		output (object)
	end

	def vote
    	flag = params[:flag] ? params[:flag] == '1' : true
		type = 2
		object = Post.find(params[:id])
		perform_action(flag, type, object, object.user)
		output (object)
	end

	def report
    	flag = params[:flag] ? params[:flag] == '1' : true
		type = 4
		object = Post.find(params[:id])
		perform_action(flag, type, object, object.user)
		output (object)
	end

	def likes
		id = params[:post_id]
		likes = Post.unscoped.find(id).likes.limit(get_limit).offset(get_offset)
		output (likes)
	end

	def destroy
	    post = Post.find(params[:id])
	    if post.user.id == @session.user.id
	      post.destroy
	      puts 'Error saving counter for user ' + @session.user.errors.messages.flatten(2).to_s unless @session.user.decrement!("posts_count")
	      render_json ({})
	    else
	      output_error(306, "Object access is not permitted")
	    end
	end
end

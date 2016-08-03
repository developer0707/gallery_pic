class Admin::PostsController < Admin::ApplicationController

	def round_posts
		id = params[:id]
		if id.eql? 'active'
			round = Round.active_round
		else
			round = Round.find(id)
		end

		if !round
			output_error(401, "Round not found")
			return
		end

		category_id = params[:category_id]
		limit = 25
		if !category_id
			limit = 100
		end
		posts = Post.where('created_at > ? AND created_at < ? AND category_id is not NULL', round.start_date, round.end_date).order(votes_count: :desc).limit(get_limit_default(limit)).offset(get_offset)

		if category_id
			posts = posts.where(category_id: category_id)
		end
        
        posts_ids = round.winning_posts.map {|winning_post| winning_post.post_id}

		winning_posts_ids = posts_ids
		categories = Category.order(:order)
		output({:round => round, :categories => categories, :posts => posts, :winning_posts_ids => winning_posts_ids})
	end
    
    def update_round_posts
        id = params[:id]
		if id.eql? 'active'
			round = Round.active_round
		else
			round = Round.find(id)
		end

		if !round
			output_error(401, "Round not found")
			return
		end

		category_id = params[:category_id]
		limit = 25
		if !category_id
			limit = 100
		end

		if category_id
			posts = posts.where(category_id: category_id)
		end
        
        if params[:posts]
			new_posts = Post.find(params[:posts])
        else
            new_posts = []
        end

			if category_id
				round.posts.each do |old_post|
					if old_post.category_id != category_id
						new_posts << old_post
					end
				end
			end

			new_posts.each do |post|
				WinningPost.find_or_create_by(round_id: round.id, post_id: post.id)
			end

			posts_ids = new_posts.map {|post| post.id}
                        
			round.winning_posts.each do |winning_post|
				if !posts_ids.include?(winning_post.post_id)
					winning_post.destroy
				end
			end
        
        redirect_to action: :round_posts, id: id, secret_token: params[:secret_token]
    end

	def votes
		if params[:actions] && params[:actions].count > 0
			params[:actions].each do |action_id|
				if Action.exists?(action_id)
					action = Action.includes(:referenced_object).find(action_id)
					action.referenced_object.decrement!(:votes_count)
					action.destroy
				end
			end
		end

		id = params[:id]
		if id == 'active'
			round = Round.active_round
		else
			round = Round.find(id)
		end

		if !round
			output_error(401, "Round not found")
			return
		end

		post = Post.find(params[:post_id])

		categories = Category.order(:order)
		
		vote_actions = post.vote_actions.includes(:user)
		output({:round => round, :categories => categories, :vote_actions => vote_actions })
	end

end

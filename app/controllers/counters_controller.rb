class CountersController < ApplicationController
	before_action :validate_secret_token
    skip_before_action :validate_api_key

  def validate_secret_token
    if params[:secret_token] != '65eb2a63e0990015dcc7995de227fbca'
      render_json({ :well => "well"})
    end
  end

  def users
    count = User.unscoped.all.count
    index = 0
    User.unscoped.all.includes([:report_actions, :follow_actions, :follower_actions, :posts]).limit(get_limit_default(1000)).offset(get_offset).each do |user|
    	user.posts_count = user.posts.count
    	user.reports_count = user.report_actions.size
    	user.follows_count = user.follow_actions.size
    	user.followers_count = user.follower_actions.size
    	user.save
    	index = index + 1

    	puts "User: " + index.to_s + "/" + count.to_s unless index % 100 != 0
    end
    render_json({:done => index.to_s + "/" + count.to_s})
  end

  def posts
  	count = Post.unscoped.all.count
    index = 0
    Post.unscoped.all.includes([:like_actions, :report_actions, :vote_actions, :comments]).limit(get_limit_default(1000)).offset(get_offset).each do |post|
    	post.likes_count = post.like_actions.count
    	post.reports_count = post.report_actions.count
    	post.votes_count = post.vote_actions.count
    	post.comments_count = post.comments.count
    	post.save
      
      index = index + 1
      puts "Post: " + index.to_s + "/" + count.to_s unless index % 100 != 0
    end
    render_json({:done => index.to_s + "/" + count.to_s})
  end

  def comments
  	count = Comment.unscoped.all.count
	index = 0
    Comment.unscoped.all.includes([:like_actions, :report_actions]).limit(get_limit_default(1000)).offset(get_offset).each do |comment|
    	comment.likes_count = comment.like_actions.count
    	comment.reports_count = comment.report_actions.count
    	comment.save
    	
		index = index + 1

		puts "Comment: " + index.to_s + "/" + count.to_s unless index % 100 != 0
    end
    render_json({:done => index.to_s + "/" + count.to_s})
  end
end

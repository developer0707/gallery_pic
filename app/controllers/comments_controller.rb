class CommentsController < UserActionController
  def index
    post_id = params[:post_id]
    comments = Comment.unblocked(@session.user).where(post_id: post_id).order(:created_at).limit(get_limit).offset(get_offset)
    output (comments)
  end

  def create
    caption = params[:data][:caption]
    post_id = 0
    if params[:post_id]
      post_id = params[:post_id].to_i
    elsif params[:data][:post_id]
      post_id = params[:data][:post_id]
    elsif params[:data][:post]
      post_id = params[:data][:post][:id]
    end

    if post_id == 0
      output_error(401, "Missing post or post_id")
      return
    end

    post = Post.find(post_id)

    comment = Comment.new
    comment.caption = caption
    comment.user_id = @session.user_id
    comment.post_id = post_id

    if params[:data][:text_mentions]
      text_mentions = params[:data][:text_mentions]

      if text_mentions.instance_of? Hash
        text_mentions = text_mentions.values
      end

      text_mentions.each do |text_mention|
        referenced_user_id  = 0
        mention_start = text_mention[:mention_start].to_i
        mention_end = text_mention[:mention_end].to_i
        if text_mention[:referenced_user_id]
          referenced_user_id = text_mention[:referenced_user_id].to_i
        elsif text_mention[:referenced_user][:id]
          referenced_user_id = text_mention[:referenced_user][:id].to_i
        end
        if referenced_user_id != 0
          text_mention = TextMention.unscoped.new(user_id: @session.user_id, referenced_user_id:referenced_user_id, mention_start:mention_start, mention_end: mention_end)
          comment.text_mentions << text_mention
        end
      end
    end

    if comment.save
      attribute = attribute_name_for_action_type(5)
      puts 'Error saving counter for post ' + post.errors.messages.flatten(2).to_s unless post.increment!(attribute)

      if comment.user_id != post.user_id
        #Add action for user comment
        action = Action.create(user_id: @session.user.id, action_type:5, referenced_object:post, referenced_user:post.user)
        push_action action
      end

      users = post.comments.where.not(user_id: @session.user_id, user_id: post.user_id).map {|comment| comment.user_id}
      users.uniq!
      
      #commentsback actions
      users.each do |referenced_user_id|
        action = Action.create(user_id: @session.user_id, action_type:8, referenced_object:post, referenced_user_id:referenced_user_id)
        push_action action
      end

      #mentions actions
      if comment.text_mentions && comment.text_mentions.count > 0
        mentioned_users = comment.text_mentions.map {|text_mention| text_mention.referenced_user_id}
        mentioned_users.uniq!

        mentioned_users.each do |referenced_user_id|
          action = Action.create(user_id: @session.user_id, action_type:9, referenced_object:comment, referenced_user_id:referenced_user_id)
          push_action action
        end
      end

      output (comment)
    else
      output_error(302, "Failed to save comment. " + comment.errors.messages.flatten(2).to_s)
    end
  end

  def like
    flag = params[:flag] ? params[:flag] == '1' : true
    type = 6
    object = Comment.find(params[:id])
    perform_action(flag, type, object, object.user)
    output (object)
  end

  def likes
    id = params[:comment_id]
    likes = Comment.unscoped.find(id).likes.limit(get_limit).offset(get_offset)
    output(likes)
  end

  def report
    flag = params[:flag] ? params[:flag] == '1' : true
    type = 7
    object = Comment.find(params[:id])
    perform_action(flag, type, object, object.user)
    output (object)
  end

  def destroy
    comment = Comment.find(params[:id])
    if comment.user.id == @session.user.id
      post = comment.post
      comment.destroy
      puts 'Error saving counter for post ' + post.errors.messages.flatten(2).to_s unless post.decrement!("comments_count")
      render ({})
    else
      output_error(306, "Object access is not permitted")
    end
  end
end

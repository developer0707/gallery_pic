attributes :id, :caption, :created_at, :likes_count
child(:user, partial: 'users/base')
node(:liked) { |comment| comment.liked_by?(@session.user_id) }
child(:text_mentions, partial: 'text_mentions/base')
child(:post, partial: 'posts/base')
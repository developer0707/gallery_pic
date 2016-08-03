attributes :id, :caption, :created_at, :likes_count, :votes_count, :comments_count
child(:user, partial: 'users/base')
child(:thumbnail, partial: 'media_files/base')
child(:photo, partial: 'media_files/base')
child(:video, partial: 'media_files/base')
child(:category, partial: 'categories/base')
child(:place, partial: 'places/base')
node(:liked) { |post| post.liked_by?(@session.user_id) }
node(:voted) { |post| post.voted_by?(@session.user_id) }
child(:text_mentions, partial: 'text_mentions/base')
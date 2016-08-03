attributes :id, :name, :username, :first_name, :last_name, :posts_count, :followers_count, :follows_count, :bio, :link
child(:thumbnail, partial: 'media_files/base')
node(:followed) { |user| user.followed_by?(@session.user_id) }
attributes :gender, :birthdate, :address, :street_address, :zip_code, if: ->(user) { user.id == @session.user_id }
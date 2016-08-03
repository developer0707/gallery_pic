attributes :id, :start_date, :end_date
child(winning_posts: :posts) do |winning_post|
	glue(:post) do |post|
		extends('posts/base')
	end
end
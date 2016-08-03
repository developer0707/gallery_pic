attributes :id, :created_at
node(:referenced_object) do |action|
	if action.referenced_object
		if action.referenced_object_type == "Post"
	    	partial('posts/base', object: action.referenced_object)
		elsif action.referenced_object_type == "User"
	    	partial('users/base', object: action.referenced_object)
		elsif action.referenced_object_type == "Comment"
	    	partial('comments/base', object: action.referenced_object)
		end
	end
end
child(:user, partial: 'users/base')
node(:type) { |action| action.action_type }

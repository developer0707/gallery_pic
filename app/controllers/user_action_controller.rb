require 'parse-ruby-client'

##
# This class should be parent for ActionControllers that require user access token.
class UserActionController < ApplicationController
	before_action :validate_session_exists

	# Creates or removes Action object for given parameters.
	# flag this is param
	def perform_action(flag, type, object, referenced_user)
		attribute = attribute_name_for_action_type(type)
		if flag
			action = Action.find_by(user_id: @session.user.id, action_type:type, referenced_object:object, referenced_user:referenced_user)

			if !action
				action = Action.create(user_id: @session.user.id, action_type:type, referenced_object:object, referenced_user:referenced_user)

				object.increment!(attribute)
				if type == 3
					action.user.increment!("follows_count")
				end

				push_action action
			end
		else
			action = Action.find_by(user_id: @session.user.id, action_type:type, referenced_object:object)
			if action
				object.decrement!(attribute)
				if type == 3
					action.user.decrement!("follows_count")
				end
				action.destroy
			end
		end
	end

	def validate_file(file_id)
		if file_id
	      	file = MediaFile.unscoped.find(file_id)
	      	if !file
	          	output_error(301, "Invalid picture id")
	        	return false
	      	end
	    end
	    return true
	end

	def attribute_name_for_action_type(type)
		if type == 1 || type == 6
			return "likes_count"
		elsif type == 2
			return "votes_count"
		elsif type == 3
			return "followers_count"
		elsif type == 4 || type == 7 || type == 11
			return "reports_count"
		elsif type == 5
			return "comments_count"
		elsif type == 12
			return "blocks_count"
		else 
			return false
		end
	end

	def push_action(action)
		if action.user_id == action.referenced_user_id
			return
		end

		type = action.action_type
		if type == 4 || type == 7 || type == 11 || type == 12
			return
		end


		begin
			installations = Installation.where(user_id: action.referenced_user_id).map {|installation| installation.id}

			puts "Pushing action " + action.to_json + "\ninstallations: " + installations.to_json
			
			if installations.count > 0
				title = ''
				uri = 'piccmee://main/'
				user = action.user
				icon = nil
				if user.thumbnail
					icon = user.thumbnail.url ? request.base_url + user.thumbnail.url : user.thumbnail.parse_url
				end

				if type == 1
					title = user.name + " liked your photo."
					uri += "post?id=" + action.referenced_object_id.to_s
				elsif type == 2
					title = user.name + " voted for your photo."
					uri += "vote?id=" + action.referenced_object_id.to_s
				elsif type == 3
					title = user.name + " started following you."
					uri += "user?id=" + action.user_id.to_s
				elsif type == 5
					title = user.name + " commented on your photo."
					uri += "post?id=" + action.referenced_object_id.to_s
				elsif type == 6
					title = user.name + " liked your comment."
					uri += "post?id=" + action.referenced_object.post_id.to_s
				elsif type == 8
					owner = action.referenced_object.user
					title = user.name + " also commented on "
					if user.id == owner.id
						title += user.gender == "male" ? "his" : "her"
					else
						title += owner.name + "'s"
					end
					title += " photo."
					uri += "post?id=" + action.referenced_object_id.to_s
				elsif type == 9
					title = user.name + " mentioned you in a comment."
					uri += "post?id=" + action.referenced_object.post_id.to_s
				elsif type == 10
					title = user.name + " mentioned you in a post."
					uri += "post?id=" + action.referenced_object_id.to_s
				else
					return
				end

				client = Parse.create :application_id => "s5bUIq5byJtL7gNKaXQTc12qRcc2ffWtqU1Kzpdf",
	             :api_key        => "BeVcJb4us64FmNx7AMBxzCNkYYJLjDMeJyKqt8cN"
				data = { :alert => title, :uri => uri, :icon => icon }
				push = client.push(data)
				query = client.query(Parse::Protocol::CLASS_INSTALLATION).value_in('railsInstallationId', installations)
				push.where = query.where
				push.save
			end
		rescue Exception => e
			puts "Pushing action " + action.to_json + " exception: " + e.message
		end
	end
end

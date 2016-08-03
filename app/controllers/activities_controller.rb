class ActivitiesController < ApplicationController
	def index
		actions = @session.user.notifications.order(created_at: :desc).limit(get_limit).offset(get_offset)
		if @installation.device_type =='ios' && @installation.app_version == '0.0.9'
			actions = actions.where("action_type not in (4, 7, 9, 10, 11, 12)")
		end
  		output actions
	end
end

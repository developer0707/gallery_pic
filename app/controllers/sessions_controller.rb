class SessionsController < ApplicationController
	before_action :validate_installation_exists, only: [:create]
	before_action :validate_session_exists, only: [:destroy]

	def create
		if @session
			output_error(203, "User already logged in")
			return
		end

		login(params)
	end

	def destroy
		@installation.user = nil
		@installation.save
		@session.destroy
		render_json ({})
	end

end

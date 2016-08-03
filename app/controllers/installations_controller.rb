require 'securerandom'

class InstallationsController < ApplicationController
  before_action :validate_installation_exists, only: :update

	def installation_permit
		return [	
					:app_identifier,
					:app_name,
					:app_version,
					:badge,
					:device_token,
					:device_type,
					:time_zone,
					:google_ad_id,
					:google_ad_id_limited
				]
	end

	def create
		if @installation
			output_error(103, "Installation already exists")
			return
		end
		permits = installation_permit

		@installation = Installation.new
		@installation.attributes = (params.require(:data).permit(permits))
		@installation.installation_key = SecureRandom.hex
		if @installation.save
			output (@installation)
		  else
		  	output_error(302, @installation.errors.messages.flatten(2).to_s)
		end
	end

	def update
		if @installation.id != params[:id].to_i
			output_error(306, "Invalid installation id")
			return
		end

		permits = installation_permit
		@installation.attributes = (params.require(:data).permit(permits))

		if @session
			@installation.user = @session.user
		end

		if @installation.save
			output (@installation)
		  else
		  	ouput_error(303, @installation.errors.messages.flatten(2).to_s)
		end
	end

end

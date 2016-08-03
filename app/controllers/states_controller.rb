class StatesController < ApplicationController
  def index
  	states = Country.find(params[:country_id]).states.order(:name).limit(get_limit_default(100)).offset(get_offset)
  	output (states)
  end
end

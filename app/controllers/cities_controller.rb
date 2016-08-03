class CitiesController < ApplicationController
  def index
  	cities = State.find(params[:state_id]).cities.order(:name).limit(get_limit_default(100)).offset(get_offset)
  	output (cities)
  end
end

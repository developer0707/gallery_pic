class CountriesController < ApplicationController
  def index
  	countries = Country.order(:name).limit(get_limit_default(100)).offset(get_offset)
  	output (countries)
  end
end

class PlacesController < UserActionController
  def index
  end

  def search
  	places = Place.search(params[:query]).order(created_at: :desc).limit(get_limit).offset(get_offset)
	output(places)
  end
end

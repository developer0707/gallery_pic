class Place < ParseActiveRecord
  validates_presence_of :name, :google_place_id, :latitude, :longitude
  has_many :posts, dependent: :restrict_with_error

  def merge_from_parse_json(object_json)
  	super(object_json)
    self.name = object_json["name"]
    self.google_place_id = object_json["googlePlaceId"]
    self.latitude = object_json["latitude"]
    self.longitude = object_json["longitude"]
  end

  def set_default_values
    return true
  end

  def self.search(query)
    whereQuery = 'name LIKE ?', query + '%'
    return Place.where(whereQuery)
  end

end

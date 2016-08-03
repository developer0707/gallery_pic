class State < ParseActiveRecord
  belongs_to :country
  has_many :cities, dependent: :destroy
  default_scope { includes(:country)}
  validates_presence_of :name

  def merge_from_parse_json(object_json)
    super(object_json)
    self.name = object_json["name"]
    self.geoname_id = object_json["geonameId"]
    self.country = Country.find_by(parse_object_id: object_json["country"]["objectId"])
  end

end

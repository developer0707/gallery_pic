class City < ParseActiveRecord
  belongs_to :state
  has_many :users, dependent: :restrict_with_error
  default_scope { includes(:state)}
  validates_presence_of :name

  def merge_from_parse_json(object_json)
  	super(object_json)
    self.name = object_json["name"]
    self.geoname_id = object_json["geonameId"]
  end

end
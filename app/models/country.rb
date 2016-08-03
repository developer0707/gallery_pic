class Country < ParseActiveRecord
  belongs_to :thumbnail, class_name: "MediaFile", dependent: :destroy
  has_many :states, dependent: :destroy
  default_scope { includes(:thumbnail)}
  validates_presence_of :name

  def merge_from_parse_json(object_json)
  	super(object_json)
    self.name = object_json["name"]
    self.geoname_id = object_json["geonameId"]
    if object_json["thumbnail"]
      self.thumbnail = self.import_parse_file(object_json["thumbnail"])
    end
  end

end

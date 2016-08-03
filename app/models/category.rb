class Category < ParseActiveRecord
  belongs_to :thumbnail, class_name: "MediaFile", dependent: :destroy
  has_many :posts, dependent: :restrict_with_error
  default_scope { includes(:thumbnail)}
  validates_presence_of :thumbnail, :order, :name

  def merge_from_parse_json(object_json)
  	super(object_json)
    self.order = object_json["order"]
    self.name = object_json["name"]

    if object_json["thumbnail"]
      self.thumbnail = self.import_parse_file(object_json["thumbnail"])
    end
  end

end

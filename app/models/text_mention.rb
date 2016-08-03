class TextMention < ParseActiveRecord
  belongs_to :user
  belongs_to :referenced_object, polymorphic: true
  belongs_to :referenced_user, class_name: "User"
  default_scope { includes(:referenced_user)}

  def merge_from_parse_json(object_json)
  	super(object_json)
    self.user = User.unscoped.find_by(parse_object_id: object_json["user"]["objectId"])
    type = object_json["type"]
    class_name = nil
    if type == 1
      class_name = "Comment"
    elsif type == 2
      class_name = "Post"
    end

    if class_name != nil
      self.mention_start = object_json["start"]
      self.mention_end = object_json["end"]

      referenced_object = Object.const_get(class_name).unscoped.find_or_create_by(parse_object_id: object_json["referencedObjectId"])
      self.referenced_object = referenced_object
      self.referenced_object_type = class_name

      if object_json["referencedUser"] && object_json["referencedUser"]["objectId"]
        self.referenced_user = User.unscoped.find_by(parse_object_id: object_json["referencedUser"]["objectId"])
      end
    end
  end
end

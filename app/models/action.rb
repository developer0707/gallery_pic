
  # Action Types
  # 1 LikePhoto
  # 2 Vote
  # 3 Follow
  # 4 Report
  # 5 Comment
  # 6 LikeComment
  # 7 ReportComment
  # 8 CommentBack
  # 9 TextCommentMention
  # 10 TextPostMention
  # 11 Report User
  # 12 Block User

class Action < ParseActiveRecord
  belongs_to :user
  belongs_to :referenced_user, class_name: "User"
  belongs_to :referenced_object, polymorphic: true
  validates_presence_of :action_type

	def merge_from_parse_json(object_json)
		super(object_json)
		self.action_type = object_json["type"]
	    self.user = User.unscoped.find_by(parse_object_id: object_json["user"]["objectId"])
	    class_name = object_json["references"][0]["className"]
	    if class_name.starts_with?('_')
	      class_name.slice!(0)
	    elsif class_name == 'PhotoPost'
	      class_name = "Post"
	    end
	    referenced_object = Object.const_get(class_name).unscoped.find_or_create_by(parse_object_id: object_json["referencedObjectId"])
	    self.referenced_object = referenced_object
	    self.referenced_object_type = class_name

      if object_json["referencedUser"] && object_json["referencedUser"]["objectId"]
        self.referenced_user = User.unscoped.find_by(parse_object_id: object_json["referencedUser"]["objectId"])
      end
	end
end
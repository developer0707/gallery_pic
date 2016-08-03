class Post < ParseActiveRecord
  belongs_to :category
  belongs_to :user
  belongs_to :place

  belongs_to :photo, class_name: "MediaFile", dependent: :destroy
  belongs_to :thumbnail, class_name: "MediaFile", dependent: :destroy
  belongs_to :video, class_name: "MediaFile", dependent: :destroy

  has_many :comments, dependent: :destroy

  has_many :referenced_actions, as: :referenced_object, class_name: "Action", dependent: :destroy
  has_many :like_actions, -> { where action_type: 1 }, as: :referenced_object, class_name: "Action"
  has_many :vote_actions, -> { where action_type: 2 }, as: :referenced_object, class_name: "Action"
  has_many :report_actions, -> { where action_type: 4 }, as: :referenced_object, class_name: "Action"
  has_many :likes, through: :like_actions, source: :user, class_name: "User"
  has_many :votes, through: :vote_actions, source: :user, class_name: "User"

  has_many :text_mentions, as: :referenced_object, dependent: :destroy

  has_many :winning_posts, dependent: :destroy

  validates_presence_of :photo
  
  default_scope { includes([:category, :user, :place, :thumbnail, :video, :photo, :text_mentions])}

  def self.unblocked(user)
    Post.where.not("`posts`.`user_id` in (?) or `posts`.`id` in (?) or `posts`.`user_id` in (?)", user.blocked_users.select("id"), user.reported_posts.select("id"), user.blocking_users.select("id"))
  end

  def merge_from_parse_json(object_json)
    super(object_json)
    self.caption = object_json["caption"]
    self.user = User.unscoped.find_by(parse_object_id: object_json["user"]["objectId"])
    self.category = Category.unscoped.find_by(parse_object_id: object_json["category"]["objectId"]) unless !object_json["category"]
    self.place = Place.unscoped.find_by(parse_object_id: object_json["place"]["objectId"]) unless !object_json["place"]

    if object_json["thumbnail"]
      self.thumbnail = self.import_parse_file(object_json["thumbnail"])
    end

    if object_json["photo"]
      self.photo = self.import_parse_file(object_json["photo"])
    end

    if object_json["video"]
      self.photo = self.import_parse_file(object_json["video"])
    end
  end

  def set_default_values
    thumbnail = thumbnail_from_file(self.photo_id, self.user_id)
    if thumbnail
      self.thumbnail_id = thumbnail.id
    end
    return true
  end

  def liked_by?(user_id)
    return Action.unscoped.find_by(user_id: user_id, action_type: 1, referenced_object: self) != nil
  end

  def voted_by?(user_id)
    return Action.unscoped.find_by(user_id: user_id, action_type: 2, referenced_object: self) != nil
  end

  def reported_by?(user_id)
    return Action.unscoped.find_by(user_id: user_id, action_type: 4, referenced_object: self) != nil
  end

end
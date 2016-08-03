class Comment < ParseActiveRecord
  belongs_to :user
  belongs_to :post

  has_many :referenced_actions, as: :referenced_object, class_name: "Action", dependent: :destroy
  has_many :like_actions, -> { where action_type: 6 }, as: :referenced_object, class_name: "Action"
  has_many :likes, through: :like_actions, source: :user, class_name: "User"
  has_many :report_actions, -> { where action_type: 7 }, as: :referenced_object, class_name: "Action"
  
  has_many :text_mentions, as: :referenced_object, dependent: :destroy
  
  default_scope { includes([:user, :post, :text_mentions])}

  def self.unblocked(user)
    Comment.where.not("`comments`.`user_id` in (?) or `comments`.`user_id` in (?)", user.blocked_users.select("id"), user.blocking_users.select("id"))
  end

  def merge_from_parse_json(object_json)
  	super(object_json)
    self.caption = object_json["caption"]
    self.user = User.unscoped.find_by(parse_object_id: object_json["user"]["objectId"]) unless !object_json["user"]
    self.post = Post.unscoped.find_by(parse_object_id: object_json["post"]["objectId"]) unless !object_json["post"]
  end

  def set_default_values
    return true
  end

  def liked_by?(user_id)
    return Action.unscoped.find_by(user_id: user_id, action_type: 6, referenced_object: self) != nil
  end

  def reported_by?(user_id)
    return Action.unscoped.find_by(user_id: user_id, action_type: 7, referenced_object: self) != nil
  end

end

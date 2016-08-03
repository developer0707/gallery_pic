class User < ParseActiveRecord
  has_many :sessions, dependent: :delete_all
  has_many :installations, dependent: :destroy

  belongs_to :city

  has_many :media_files, dependent: :destroy

  belongs_to :profile_picture, class_name: "MediaFile", dependent: :destroy
  belongs_to :thumbnail, class_name: "MediaFile", dependent: :destroy

  has_many :posts, dependent: :destroy

  has_many :referral_codes, dependent: :destroy

  has_many :actions, dependent: :destroy
  has_many :referenced_actions, class_name: "Action", foreign_key: "referenced_user_id", dependent: :destroy

  has_many :notifications, -> {where action_type: [1, 2, 3, 5, 6, 8, 9, 10]}, class_name: "Action", foreign_key: "referenced_user_id"
  #follow actions
  has_many :follower_actions, -> { where action_type: 3 }, as: :referenced_object, class_name: "Action"
  has_many :follow_actions, -> { where action_type: 3 }, class_name: "Action"
  has_many :follows, through: :follow_actions, source: :referenced_object, source_type: "User"
  has_many :news_posts, through: :follows, source: :posts
  has_many :followers, through: :follower_actions, source: :user

  #reports and blocks
  has_many :report_actions, -> { where action_type: 11 }, source: :user, class_name: "Action"
  has_many :block_actions, -> {where action_type: 12}, source: :user, class_name: "Action"
  has_many :blocked_users, through: :block_actions, source: :referenced_object, source_type: "User"

  has_many :blocking_actions, -> {where action_type: 12}, as: :referenced_object, class_name: "Action"
  has_many :blocking_users, through: :blocking_actions, source: :user

  has_many :reported_posts_actions, -> { where action_type: 4}, class_name: "Action", source: :user
  has_many :reported_posts, through: :reported_posts_actions, source: :referenced_object, source_type: "Post"

  default_scope { includes([:city, :profile_picture, :thumbnail])}
  has_secure_password
  # validates_uniqueness_of :username

  def self.unblocked(user)
    User.where.not("`users`.`id` in (?) or `users`.`id` in (?)", user.blocked_users.select("id"), user.blocking_users.select("id"))
  end

  def merge_from_parse_json(object_json)
    super(object_json)
    self.username = object_json["username"]
    self.email = object_json["email"]
    self.first_name = object_json["firstName"]
    self.last_name = object_json["lastName"]
    self.gender = object_json["gender"]
    self.address = object_json["address"]
    self.street_address = object_json["street"]
    self.password_digest = object_json["bcryptPassword"] unless !object_json["bcryptPassword"]

    #if parse didn't send a password, we generate a random one so saving user would succeed
    if !self.password_digest
      self.password = Array.new(10).map { (65 + rand(58)).chr }.join
    end

    if object_json["profile_picture"]
      self.photo = self.import_parse_file(object_json["profile_picture"])
    end

    if object_json["thumbnail"]
      self.thumbnail = self.import_parse_file(object_json["thumbnail"])
    end

    self.email_verified = object_json["emailVerified"]
    self.zip_code = object_json["zipCode"]
    self.verified = object_json["verified"]
    self.name = object_json["name"]
    self.city = City.unscoped.find_by(parse_object_id: object_json["city"]["objectId"]) unless !object_json["city"]
    facebook_json = object_json["authData"]["facebook"] unless !object_json["authData"]
    if facebook_json
      self.facebook_token = facebook_json["access_token"]
      self.facebook_id = facebook_json["id"]
    end
  end

  def set_default_values
    self.name = (self.first_name + " " + self.last_name) unless !self.first_name

    thumbnail = thumbnail_from_file(self.profile_picture_id, self.id)
    if thumbnail
      self.thumbnail = thumbnail
    end
    
    return true
  end

  def followed_by?(user_id)
    return Action.unscoped.find_by(user_id: user_id, action_type: 3, referenced_object: self) != nil
  end

  def self.search(query, user_id = nil)
    whereQuery = '(email = ? OR username LIKE ? OR first_name LIKE ? OR last_name LIKE ? OR name LIKE ?)'
    if user_id
      whereQuery = whereQuery + " AND (select count(*) from actions where actions.action_type = 3 and (actions.referenced_user_id = " + user_id.to_s + " or actions.user_id = " + user_id.to_s + ") > 0)"
    end
    whereQuery = whereQuery, query, query + '%', query + '%', query + '%', query + '%'
    return User.where(whereQuery)
  end

end
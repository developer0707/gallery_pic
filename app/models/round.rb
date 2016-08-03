class Round < ParseActiveRecord
	has_many :winning_posts, -> { order(order: :desc) }, dependent: :destroy
  has_many :posts, through: :winning_posts
  
  validates_presence_of :start_date, :end_date

  def self.active_round
    return Round.find_by(['start_date < ? AND end_date > ?', DateTime.now, DateTime.now])
  end

  def merge_from_parse_json(object_json)
    super(object_json)
    self.start_date = object_json["startDate"]["iso"] unless !object_json["startDate"]
    self.end_date = object_json["endDate"]["iso"] unless !object_json["endDate"]

    posts = object_json["winningPosts"]
    if posts
      posts.each do |post_json|
        post = Post.unscoped.find_by(parse_object_id: post_json["objectId"])
        exists = false
        self.winning_posts.each do |winning_post|
          if post.id == winning_post.post_id
            exists = true
            break
          end
        end
        if !exists
          winning_post = WinningPost.new
          winning_post.round = self
          winning_post.post_id = post.id
          self.winning_posts << winning_post
        end
      end
    end
  end

end

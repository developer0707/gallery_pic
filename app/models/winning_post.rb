class WinningPost < ParseActiveRecord
  belongs_to :round
  belongs_to :post
  
  validates_presence_of :round, :post

  default_scope { includes(:post)}

end

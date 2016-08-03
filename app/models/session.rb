class Session < ParseActiveRecord
  belongs_to :user
  belongs_to :installation
  validates_presence_of :user, :installation
  
end
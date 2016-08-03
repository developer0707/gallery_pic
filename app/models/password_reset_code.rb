class PasswordResetCode < ActiveRecord::Base
  belongs_to :user

  def expired?
  	self.expire_date < DateTime.now || self.used
  end
end

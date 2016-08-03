class UserMailer < ApplicationMailer
  default from: 'PiccMee <technical@piccmee.com>'
  def reset_password(user, url)
  	@user = user
  	@url = url
  	mail(to: @user.email, subject: 'Reset PiccMee Password')
  end
end

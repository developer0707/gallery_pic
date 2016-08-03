require 'securerandom'

class ReferralCodesController < UserActionController
  def create

  	data = {:url => "http://get.piccmee.com", :title => "PiccMee", :description => "PiccMee is app with a simple concept, Upload, Vote, Win!!! Users can upload pictures to several different categories, allow those pictures to be voted on, and at the end of each contest the users with the most votes in each category wins free cool prizes (Flat screen T.V's, Tablets, Smart Phones, and many more cool free prizes). Users can also be randomly picked to win these free prizes just by being social. For example, by posting the most the pictures, following the most people or inviting the most people to the app can get you randomly picked to win free prizes. We never ask for a credit card and you never pay for shipping and handling. This app is completely free and so are the prizes you win. Piccmee is a social app that gives back to the people and actually makes social media fun for people of all ages."}
  	
  	render_json({:data => data})
  	# code = SecureRandom.hex
  	# referral_code = ReferralCode.find_or_create_by(user_id: @session.user_id, code: code)
  	# output(referral_code)
  end
end
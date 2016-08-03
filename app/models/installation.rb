require 'securerandom'
class Installation < ParseActiveRecord
	belongs_to :user
	has_many :sessions, dependent: :delete_all

	validates_presence_of :app_identifier,
							:app_name,
							:app_version,
							:device_type,
							:installation_key

  def merge_from_parse_json(object_json)
  	super(object_json)
    self.app_identifier = object_json["appIdentifier"]
    self.app_name = object_json["appName"]
    self.parse_installation_id = object_json["installationId"]
    self.app_version = object_json["appVersion"]
    self.badge = object_json["badge"]
    self.device_token = object_json["deviceToken"]
    self.device_token_last_modified = object_json["deviceTokenLastModified"]
    self.device_type = object_json["deviceType"]
    self.time_zone = object_json["timeZone"]
    self.google_ad_id = object_json["google_ad_id"]
    self.google_ad_id_limited = object_json["google_ad_id_limited"]
    self.user = User.find_by(parse_object_id: object_json["user"]["objectId"]) unless !object_json["user"]
    self.installation_key = SecureRandom.hex
  end

end
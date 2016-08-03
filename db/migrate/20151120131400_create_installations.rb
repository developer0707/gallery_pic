class CreateInstallations < ActiveRecord::Migration
  def change
    create_table :installations do |t|
      t.string :parse_object_id
      t.string :parse_installation_id
      t.string :app_identifier
      t.string :app_name
      t.string :app_version
      t.integer :badge
      t.text :device_token
      t.string :device_token_last_modified
      t.string :device_type
      t.text :installation_key
      t.string :time_zone
      t.text :google_ad_id
      t.boolean :google_ad_id_limited
      t.integer :user_id

      t.timestamps null: false
    end
  end
end

class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :parse_object_id
      t.string :username
      t.string :name
      t.string :password_digest
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :gender
      t.text :address
      t.text :street_address
      t.references :profile_picture
      t.references :thumbnail
      t.text :facebook_token
      t.string :facebook_id
      t.datetime :facebook_token_expire_date
      t.boolean :email_verified
      t.datetime :birthdate
      t.string :zip_code
      t.boolean :verified
      t.references :city, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

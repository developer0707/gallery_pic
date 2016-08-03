class CreatePasswordResetCodes < ActiveRecord::Migration
  def change
    create_table :password_reset_codes do |t|
      t.references :user, index: true, foreign_key: true
      t.string :code
      t.datetime :expire_date
      t.boolean :used

      t.timestamps null: false
    end
  end
end

class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.string :access_token
      t.references :user, index: true, foreign_key: true
      t.references :installation, index: true, foreign_key: true
      t.datetime :expire_date
      t.boolean :expired

      t.timestamps null: false
    end
  end
end

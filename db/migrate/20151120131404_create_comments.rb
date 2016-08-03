class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :parse_object_id
      t.text :caption
      t.references :user, index: true, foreign_key: true
      t.references :post, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

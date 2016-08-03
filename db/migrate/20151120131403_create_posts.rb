class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :parse_object_id
      t.text :caption
      t.references :category, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.references :place, index: true, foreign_key: true
      t.references :photo
      t.references :thumbnail
      t.references :video

      t.timestamps null: false
    end
  end
end

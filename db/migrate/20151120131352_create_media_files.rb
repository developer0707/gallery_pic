class CreateMediaFiles < ActiveRecord::Migration
  def change
    create_table :media_files do |t|
      t.text :parse_url
      t.text :url
      t.string :name, null: false

      t.timestamps null: false
    end
  end
end

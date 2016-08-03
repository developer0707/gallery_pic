class CreatePlaces < ActiveRecord::Migration
  def change
    create_table :places do |t|
      t.string :parse_object_id
      t.string :name
      t.string :google_place_id
      t.float :latitude
      t.float :longitude

      t.timestamps null: false
    end
  end
end

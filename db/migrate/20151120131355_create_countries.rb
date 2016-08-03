class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :parse_object_id
      t.string :name, null: false
      t.integer :geoname_id
      t.references :thumbnail

      t.timestamps null: false
    end
  end
end

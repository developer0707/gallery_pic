class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string :parse_object_id
      t.string :name, null: false
      t.integer :geoname_id
      t.references :state, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

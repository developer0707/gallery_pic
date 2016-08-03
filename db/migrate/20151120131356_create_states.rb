class CreateStates < ActiveRecord::Migration
  def change
    create_table :states do |t|
      t.string :parse_object_id
      t.string :name, null: false
      t.integer :geoname_id
      t.references :country, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

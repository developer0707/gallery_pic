class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :parse_object_id
      t.string :name, null:false
      t.integer :order, null:false
      t.references :thumbnail

      t.timestamps null: false
    end
  end
end

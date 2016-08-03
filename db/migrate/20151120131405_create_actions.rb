class CreateActions < ActiveRecord::Migration
  def change
    create_table :actions do |t|
      t.string :parse_object_id
      t.references :user, index: true, foreign_key: true
      t.integer :action_type, index: true
      t.references :referenced_object, index: true
      t.string :referenced_object_type, index: true
      t.references :referenced_user, index: true

      t.timestamps null: false
    end
  end
end

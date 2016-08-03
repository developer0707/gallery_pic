class CreateTextMentions < ActiveRecord::Migration
  def change
    create_table :text_mentions do |t|
      t.string :parse_object_id
      t.references :user, index: true, foreign_key: true
      t.references :referenced_object, index: true
      t.string :referenced_object_type
      t.references :referenced_user, index: true
      t.integer :mention_start
      t.integer :mention_end

      t.timestamps null: false
    end
  end
end

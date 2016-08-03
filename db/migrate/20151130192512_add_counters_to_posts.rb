class AddCountersToPosts < ActiveRecord::Migration
  def up
    add_column :posts, :likes_count, :integer, :default => 0, :null => false
    add_column :posts, :reports_count, :integer, :default => 0, :null => false
    add_column :posts, :votes_count, :integer, :default => 0, :null => false
    add_column :posts, :comments_count, :integer, :default => 0, :null => false
  end

  def down
  	remove_column :posts, :likes_count
  	remove_column :posts, :reports_count
  	remove_column :posts, :votes_count
  	remove_column :posts, :comments_count
  end
end

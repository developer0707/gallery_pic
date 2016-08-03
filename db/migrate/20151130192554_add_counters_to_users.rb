class AddCountersToUsers < ActiveRecord::Migration
  def up
    add_column :users, :posts_count, :integer, :default => 0, :null => false
    add_column :users, :reports_count, :integer, :default => 0, :null => false
    add_column :users, :followers_count, :integer, :default => 0, :null => false
    add_column :users, :follows_count, :integer, :default => 0, :null => false
  end

  def down
  	remove_column :users, :posts_count
  	remove_column :users, :reports_count
  	remove_column :users, :followers_count
  	remove_column :users, :follows_count
  end
end

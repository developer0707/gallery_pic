class AddCountersToComments < ActiveRecord::Migration
	def up
	    add_column :comments, :likes_count, :integer, :default => 0, :null => false
	    add_column :comments, :reports_count, :integer, :default => 0, :null => false
	end

	def down
		remove_column :comments, :likes_count
		remove_column :comments, :reports_count
	end
end

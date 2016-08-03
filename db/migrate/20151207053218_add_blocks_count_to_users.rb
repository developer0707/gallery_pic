class AddBlocksCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :blocks_count, :integer
  end
end

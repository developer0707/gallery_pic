class AddOrderToWinningPosts < ActiveRecord::Migration
  def change
    add_column :winning_posts, :order, :integer
  end
end

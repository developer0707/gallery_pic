class CreateWinningPosts < ActiveRecord::Migration
  def change
    create_table :winning_posts do |t|
      t.references :round, index: true, foreign_key: true
      t.references :post, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

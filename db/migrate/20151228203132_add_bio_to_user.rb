class AddBioToUser < ActiveRecord::Migration
  def change
    add_column :users, :bio, :text
    add_column :users, :link, :string
  end
end

class AddColomToChatrooms < ActiveRecord::Migration
  def change
    add_column :chatrooms, :friend_id, :integer, index: true, foreign_key: true
  end
end

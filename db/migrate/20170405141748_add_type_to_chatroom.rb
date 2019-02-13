class AddTypeToChatroom < ActiveRecord::Migration
  def change
    add_column :chatrooms, :chatroom_type, :int
    remove_column :chatrooms, :user_id, :int
    remove_column :chatrooms, :recipient_id, :int
    remove_column :chatrooms, :name
  end
end

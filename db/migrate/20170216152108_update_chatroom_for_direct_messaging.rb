class UpdateChatroomForDirectMessaging < ActiveRecord::Migration
  def change
    rename_column :chatrooms, :friend_id, :recipient_id
  end
end

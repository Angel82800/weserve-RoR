class AddUuidIndexToChatSessions < ActiveRecord::Migration
  def change
    add_index :chat_sessions, :uuid
  end
end

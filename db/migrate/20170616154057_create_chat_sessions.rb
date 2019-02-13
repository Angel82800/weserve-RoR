class CreateChatSessions < ActiveRecord::Migration
  def change
    create_table :chat_sessions do |t|
      t.string :uuid
      t.string :status
      t.references :requester, index: true
      t.references :receiver, index: true

      t.timestamps null: false
    end
  end
end

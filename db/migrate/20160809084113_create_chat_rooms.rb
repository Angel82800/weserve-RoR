class CreateChatRooms < ActiveRecord::Migration
  def change
    create_table :chat_rooms do |t|
      t.string :chat_rooms, :room_id, :string
      t.references :project, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end

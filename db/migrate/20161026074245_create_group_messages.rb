class CreateGroupMessages < ActiveRecord::Migration
  def change
    create_table :group_messages do |t|
      t.string :message
      t.references :user, index: true, foreign_key: true
      t.references :chatroom, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

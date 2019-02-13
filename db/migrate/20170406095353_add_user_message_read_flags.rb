class AddUserMessageReadFlags < ActiveRecord::Migration
  def change
    create_table :user_message_read_flags do |t|
      t.boolean :read_status, default: false
      t.references :user, index: true, foreign_key: true
      t.references :group_message, index: true, foreign_key: true
      t.timestamps
    end

    add_index :user_message_read_flags, [:user_id, :group_message_id], unique: true

  end
end

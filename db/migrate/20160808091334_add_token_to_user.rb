class AddTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :chat_token, :string
    add_column :users, :guid, :string
  end
end

class AddBackupToUsers < ActiveRecord::Migration
  def change
    add_column :user_wallet_addresses, :user_keys, :string
    add_column :user_wallet_addresses, :backup_keys, :string
  end
end

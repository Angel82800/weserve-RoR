class DropOldWalletAddresses < ActiveRecord::Migration
  def change
    drop_table :user_wallet_addresses
    drop_table :wallet_addresses
  end
end

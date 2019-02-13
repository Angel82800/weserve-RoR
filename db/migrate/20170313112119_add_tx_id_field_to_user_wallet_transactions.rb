class AddTxIdFieldToUserWalletTransactions < ActiveRecord::Migration
  def change
    add_column :user_wallet_transactions, :tx_id, :string
    rename_column :user_wallet_transactions, :tx_hash, :tx_hex
  end
end

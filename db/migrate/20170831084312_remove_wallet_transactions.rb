class RemoveWalletTransactions < ActiveRecord::Migration
  def change
    drop_table :wallet_transactions
  end
end

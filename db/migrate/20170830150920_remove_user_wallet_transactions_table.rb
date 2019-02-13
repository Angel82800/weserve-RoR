class RemoveUserWalletTransactionsTable < ActiveRecord::Migration
  def change
    drop_table :user_wallet_transactions
  end
end

class AddTxInternalIdToUserWalletTransactions < ActiveRecord::Migration
  def change
    add_column :user_wallet_transactions, :tx_internal_id, :string
  end
end

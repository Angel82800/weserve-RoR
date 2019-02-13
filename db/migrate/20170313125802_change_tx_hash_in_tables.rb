class ChangeTxHashInTables < ActiveRecord::Migration
  def change
    add_column :stripe_payments, :tx_id, :string
    rename_column :stripe_payments, :tx_hash, :tx_hex

    add_column :wallet_transactions, :tx_id, :string
    rename_column :wallet_transactions, :tx_hash, :tx_hex
  end
end

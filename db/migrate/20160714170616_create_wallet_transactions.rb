class CreateWalletTransactions < ActiveRecord::Migration
  def change
    create_table :wallet_transactions do |t|
      t.decimal :amount
      t.string :user_wallet
      t.string :tx_hash
      t.references :task, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

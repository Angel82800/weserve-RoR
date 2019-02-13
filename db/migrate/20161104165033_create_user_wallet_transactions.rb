class CreateUserWalletTransactions < ActiveRecord::Migration
  def change
    create_table :user_wallet_transactions do |t|
      t.decimal :amount
      t.string :user_wallet
      t.string :tx_hash
      t.integer :user_id
      t.timestamps null: false
    end
  end
end

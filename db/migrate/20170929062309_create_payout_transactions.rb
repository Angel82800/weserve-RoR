class CreatePayoutTransactions < ActiveRecord::Migration
  def change
    create_table :payout_transactions do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :payout_provider
      t.string :target_account
      t.string :transaction_id
      t.integer :status
      t.integer :amount
      t.integer :fee

      t.timestamps null: false
    end
  end
end

class CreatePaymentTransactions < ActiveRecord::Migration
  def change
    create_table :payment_transactions do |t|
      t.references :task, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.integer :amount
      t.string :status
      t.string :payment_type
      t.string :payment_provider
      t.string :payment_token
      t.integer :processing_fee

      t.timestamps null: false
    end
  end
end

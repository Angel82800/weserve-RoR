class CreateTransactionHistories < ActiveRecord::Migration
  def change
    create_table :transaction_histories do |t|
      t.integer :entity
      t.integer :entity_balance
      t.string :operation_type
      t.integer :source
      t.integer :amount

      t.timestamps null: false
    end
  end
end

class CreateHoldBalances < ActiveRecord::Migration
  def change
    create_table :hold_balances do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :amount

      t.timestamps null: false
    end
  end
end

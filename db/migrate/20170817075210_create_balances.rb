class CreateBalances < ActiveRecord::Migration
  def change
    create_table :balances do |t|
      t.integer :user_id
      t.integer :task_id
      t.integer :amount, default: 0
      t.integer :funded, default: 0

      t.timestamps null: false
    end
  end
end

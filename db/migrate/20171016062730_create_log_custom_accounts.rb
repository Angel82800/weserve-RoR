class CreateLogCustomAccounts < ActiveRecord::Migration
  def change
    create_table :log_custom_accounts do |t|
      t.string :acct_id
      t.integer :status
      t.integer :user_id

      t.timestamps null: false
    end
  end
end

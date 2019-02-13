class CreateCustomAccounts < ActiveRecord::Migration
  def change
    create_table :custom_accounts do |t|
      t.string :acc_id
      t.integer :status, default: 0
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

class CreateBanks < ActiveRecord::Migration
  def change
    create_table :banks do |t|
      t.string :acct_id
      t.integer :status
      t.string :last4
      t.references :user, index: true
      t.timestamps null: false
    end
  end
end

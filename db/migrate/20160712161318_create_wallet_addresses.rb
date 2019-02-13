class CreateWalletAddresses < ActiveRecord::Migration
  def change
    create_table :wallet_addresses do |t|
      t.string :sender_address
      t.references :task, index: true, foreign_key: true
      t.string :wallet_addresses, :wallet_id
      t.string :wallet_addresses, :receiver_address
      t.float :wallet_addresses, :current_balance, default: 0.0
      t.string :wallet_addresses, :pass_phrase
      t.timestamps null: false
    end
  end
end

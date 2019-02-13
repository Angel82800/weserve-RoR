class CreateUserWalletAddresses < ActiveRecord::Migration
  def change
    create_table :user_wallet_addresses do |t|
      t.string :sender_address
      t.string :wallet_id
      t.string :receiver_address
      t.float :current_balance
      t.string :pass_phrase
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

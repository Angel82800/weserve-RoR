class CreateAdminReseveWallets < ActiveRecord::Migration
  def change
    create_table :admin_reseve_wallets do |t|
      t.string :sender_address
      t.string :wallet_id
      t.string :receiver_address
      t.float :current_balance
      t.string :pass_phrase
      t.string :user_keys
      t.string :backup_keys

      t.timestamps null: false
    end
  end
end

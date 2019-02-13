class CreateWallets < ActiveRecord::Migration
  def change
    create_table :wallets do |t|
      t.string :wallet_id, null: false
      t.string :receiver_address
      t.decimal :balance
      t.references :wallet_ownerable, polymorphic: true, index: true
    end

    add_index :wallets, :wallet_id, unique: true
  end
end

class DeleteAtToUserWalletTransaction < ActiveRecord::Migration
  def change
    add_column :user_wallet_transactions, :deleted_at, :datetime
    add_index :user_wallet_transactions, :deleted_at
  end
end

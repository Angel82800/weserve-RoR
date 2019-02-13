class RenameWalletsFields < ActiveRecord::Migration
  def change
    rename_column :wallets, :wallet_ownerable_id, :wallet_owner_id
    rename_column :wallets, :wallet_ownerable_type, :wallet_owner_type
  end
end

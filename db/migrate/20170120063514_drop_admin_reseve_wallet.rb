class DropAdminReseveWallet < ActiveRecord::Migration
  def change
    drop_table :admin_reseve_wallets
  end
end

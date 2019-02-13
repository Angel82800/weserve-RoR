class RemoveWalletsTable < ActiveRecord::Migration
  def change
    drop_table :wallets
  end
end

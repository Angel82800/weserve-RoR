class AddWalletBalanceDefault < ActiveRecord::Migration
  def change
    change_column :wallets, :balance, :decimal, default: 0.0
  end
end

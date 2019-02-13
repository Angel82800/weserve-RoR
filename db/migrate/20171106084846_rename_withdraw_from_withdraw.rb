class RenameWithdrawFromWithdraw < ActiveRecord::Migration
  def change
    rename_column :custom_accounts,  :withdraw, :withdrawals_enabled
  end
end

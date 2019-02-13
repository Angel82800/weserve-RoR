class RemoveStatusFromLogCustomAccounts < ActiveRecord::Migration
  def change
    remove_column :log_custom_accounts, :status, :integer
  end
end

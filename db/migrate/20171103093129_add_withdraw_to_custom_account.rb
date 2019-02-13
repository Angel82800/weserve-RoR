class AddWithdrawToCustomAccount < ActiveRecord::Migration
  def change
    add_column :custom_accounts,  :withdraw, :boolean, default: true
  end
end

class DeleteCurrentFundTaskField < ActiveRecord::Migration
  def change
    remove_column :tasks, :current_fund
  end
end

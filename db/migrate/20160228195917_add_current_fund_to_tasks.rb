class AddCurrentFundToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :current_fund, :decimal, default: 0
  end
end

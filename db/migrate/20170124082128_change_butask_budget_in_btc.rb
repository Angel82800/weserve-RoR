class ChangeButaskBudgetInBtc < ActiveRecord::Migration
  def change
    rename_column :tasks, :budget, :satoshi_budget
  end
end

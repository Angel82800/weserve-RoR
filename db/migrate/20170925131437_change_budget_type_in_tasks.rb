class ChangeBudgetTypeInTasks < ActiveRecord::Migration
  def self.up
    remove_column :tasks, :budget, :decimal
    add_column :tasks, :budget, :integer
  end

  def self.down
    remove_column :tasks, :budget, :integer
    add_column :tasks, :new_budget, :decimal
  end
end

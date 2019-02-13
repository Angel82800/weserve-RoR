class AddConditionOfExecutionToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :condition_of_execution, :text
  end
end

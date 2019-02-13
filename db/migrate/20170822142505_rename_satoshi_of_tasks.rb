class RenameSatoshiOfTasks < ActiveRecord::Migration
  def change
  	rename_column :tasks, :satoshi_budget, :budget
  end
end

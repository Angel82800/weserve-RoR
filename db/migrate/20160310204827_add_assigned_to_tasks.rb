class AddAssignedToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :assigned, :boolean, default: false
  end
end

class AddFreeToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :free, :boolean, :default => false
  end
end

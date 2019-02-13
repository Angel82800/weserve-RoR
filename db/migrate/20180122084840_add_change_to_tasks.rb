class AddChangeToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :change, :json, default: {}
  end
end

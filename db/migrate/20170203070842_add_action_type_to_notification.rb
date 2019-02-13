class AddActionTypeToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :action_type, :integer
  end
end

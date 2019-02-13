class ChangeNotificationsColumns < ActiveRecord::Migration
  def change
    add_column :notifications, :view_params, :text
    add_reference :notifications, :user, foreign_key: true
    remove_column :notifications, :type
    add_column :notifications, :kind, :integer, default: 0
  end
end

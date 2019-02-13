class AlterActionTypeFromNotificationsBackToInteger < ActiveRecord::Migration
  def up
    change_column :notifications, :action_type, 'integer USING CAST(action_type AS integer)'
  end

  def down
    change_column :notifications, :action_type, :string
  end
end

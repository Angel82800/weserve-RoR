class AddUserIdToTaskAttachment < ActiveRecord::Migration
  def change
    add_column :task_attachments, :user_id,:integer
  end
end

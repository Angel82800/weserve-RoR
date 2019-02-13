class AddAttachmentTaskComment < ActiveRecord::Migration
  def change
    add_column :task_comments, :attachment, :string
  end
end

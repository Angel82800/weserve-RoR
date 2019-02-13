class AddUserIdToProjectEdits < ActiveRecord::Migration
  def change
    add_column :project_edits, :user_id, :integer
    add_column :project_edits, :project_id, :integer
    add_column :project_edits, :description, :text
  end
end

class AddDeletedAtToProjectComments < ActiveRecord::Migration
  def change
    add_column :project_comments, :deleted_at, :datetime
    add_index :project_comments, :deleted_at
  end
end

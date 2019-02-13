class AddDeletedAtToProjectEdits < ActiveRecord::Migration
  def change
    add_column :project_edits, :deleted_at, :datetime
    add_index :project_edits, :deleted_at
  end
end

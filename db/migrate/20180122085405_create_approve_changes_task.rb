class CreateApproveChangesTask < ActiveRecord::Migration
  def change
    create_table :approve_changes_tasks do |t|
      t.integer :task_id
      t.integer :assignment_id
      t.boolean :approve, default: false
    end
  end
end

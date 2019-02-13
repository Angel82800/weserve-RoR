class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.integer :task_id
      t.integer :user_id
      t.boolean :free
      t.datetime :deadline

      t.timestamps null: false
    end

    add_index :assignments, [:task_id, :user_id]
  end
end

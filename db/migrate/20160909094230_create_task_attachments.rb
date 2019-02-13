class CreateTaskAttachments < ActiveRecord::Migration
  def change
    create_table :task_attachments do |t|
      t.integer :task_id
      t.string :attachment

      t.timestamps null: false
    end
  end
end

class CreateTaskComments < ActiveRecord::Migration
  def change
    create_table :task_comments do |t|
      t.text :body
      t.integer :user_id
      t.integer :task_id

      t.timestamps null: false
    end
  end
end

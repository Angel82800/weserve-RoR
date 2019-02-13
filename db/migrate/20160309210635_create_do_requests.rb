class CreateDoRequests < ActiveRecord::Migration
  def change
    create_table :do_requests do |t|
      t.integer :task_id
      t.string :state
      t.integer :user_id

      t.timestamps null: false
    end

    add_index :do_requests, [:task_id, :user_id]
  end
end

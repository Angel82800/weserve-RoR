class CreateDoForFrees < ActiveRecord::Migration
  def change
    create_table :do_for_frees do |t|
      t.integer :user_id
      t.integer :task_id
      t.string :state

      t.timestamps null: false
    end
  end
end

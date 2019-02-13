class CreateTaskReviews < ActiveRecord::Migration
  def change
    create_table :task_reviews do |t|
      t.integer :user_id
      t.integer :task_id
      t.integer :rating
      t.text :feedback

      t.timestamps null: false
    end
  end
end

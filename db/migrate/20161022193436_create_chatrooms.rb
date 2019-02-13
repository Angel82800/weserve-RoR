class CreateChatrooms < ActiveRecord::Migration
  def change
    create_table :chatrooms do |t|
      t.string :name
      t.integer :project_id , index: true, foreign_key: true
      t.integer :user_id , index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end

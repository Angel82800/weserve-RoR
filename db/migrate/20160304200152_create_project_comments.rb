class CreateProjectComments < ActiveRecord::Migration
  def change
    create_table :project_comments do |t|
      t.text :body
      t.integer :user_id
      t.integer :project_id

      t.timestamps null: false
    end
  end
end

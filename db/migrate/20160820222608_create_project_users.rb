class CreateProjectUsers < ActiveRecord::Migration
  def change
    create_table :project_users do |t|
      t.belongs_to :project
      t.belongs_to :user

      t.timestamps null: false
    end
  end
end

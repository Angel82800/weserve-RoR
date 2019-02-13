class CreateProjAdmins < ActiveRecord::Migration
  def change
    create_table :proj_admins do |t|
      t.integer :user_id
      t.integer :project_id

      t.timestamps null: false
    end
  end
end

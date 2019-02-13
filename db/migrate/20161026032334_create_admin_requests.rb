class CreateAdminRequests < ActiveRecord::Migration
  def change
    create_table :admin_requests do |t|
      t.references :user, index: true, foreign_key: true
      t.references :project, index: true, foreign_key: true
      t.integer :status, default: 0
      t.timestamps null: false
    end
  end
end

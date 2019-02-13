class CreateApplyRequests < ActiveRecord::Migration
  def change
    create_table :apply_requests do |t|
      t.integer :project_id
      t.integer :user_id
      t.integer :status, default: 0
      t.integer :request_type
      t.timestamps null: false
    end
  end
end

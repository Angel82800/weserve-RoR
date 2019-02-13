class AddPolymorphicAssosiationToNotifications < ActiveRecord::Migration
  def change
    remove_column :notifications, :view_params, :text
    rename_column :notifications, :kind, :action
    add_column :notifications, :source_model_id, :integer
    add_column :notifications, :source_model_type, :string
    add_column :notifications, :origin_user_id, :integer
    add_foreign_key :notifications, :users, column: :origin_user_id, on_delete: :cascade, on_update: :cascade
    add_index :notifications, :user_id
    add_index :notifications, [:source_model_type, :source_model_id]
  end
end

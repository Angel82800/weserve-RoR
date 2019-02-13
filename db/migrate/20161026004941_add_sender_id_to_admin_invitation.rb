class AddSenderIdToAdminInvitation < ActiveRecord::Migration
  def change
    add_column :admin_invitations, :sender_id, :integer
    add_foreign_key :admin_invitations, :users, column: :sender_id, on_delete: :cascade, on_update: :cascade
  end
end

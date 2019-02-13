class RemoveAdminInvitations < ActiveRecord::Migration
  def change
    drop_table :admin_invitations
  end
end

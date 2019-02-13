class AddStateToProjAdmins < ActiveRecord::Migration
  def change
    add_column :proj_admins, :state, :string
  end
end

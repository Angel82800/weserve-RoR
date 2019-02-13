class AddRoleToTeamMemberShip < ActiveRecord::Migration
  def change
    add_column :team_memberships, :role, :integer, default: 0
  end
end

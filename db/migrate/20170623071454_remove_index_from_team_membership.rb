class RemoveIndexFromTeamMembership < ActiveRecord::Migration
  def change
    remove_index :team_memberships, name: :team_membership_team_member_role_index
    add_index :team_memberships, [:team_id, :team_member_id, :role], name: :team_membership_team_member_role_index
  end
end

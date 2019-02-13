class FixInvalidTeamMembershipIndex < ActiveRecord::Migration
  def change
    remove_index :team_memberships, column: [:team_id, :team_member_id]
    add_index :team_memberships, [:team_id, :team_member_id, :role], unique: true, name: 'team_membership_team_member_role_index'
  end
end

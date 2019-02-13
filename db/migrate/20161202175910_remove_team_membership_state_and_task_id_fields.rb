class RemoveTeamMembershipStateAndTaskIdFields < ActiveRecord::Migration
  def change
    remove_column :team_memberships, :state, :string
    remove_column :team_memberships, :task_id, :integer
  end
end

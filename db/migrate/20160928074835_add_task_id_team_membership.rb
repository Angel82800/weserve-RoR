class AddTaskIdTeamMembership < ActiveRecord::Migration
  def change
    add_column :team_memberships, :task_id, :integer
  end
end

class AddColToTeamMembership < ActiveRecord::Migration
  def change
    add_column :team_memberships, :state, :string
  end
end

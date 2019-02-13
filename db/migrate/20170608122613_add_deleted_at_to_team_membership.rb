class AddDeletedAtToTeamMembership < ActiveRecord::Migration
  def change
    add_column :team_memberships, :deleted_at, :datetime
    add_column :team_memberships, :deleted_reason, :text

    add_index :team_memberships, :deleted_at
  end
end

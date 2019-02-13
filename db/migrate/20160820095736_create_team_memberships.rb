class CreateTeamMemberships < ActiveRecord::Migration
  def change
    create_table :team_memberships do |t|
      t.integer 'team_id', :null => false
      t.integer 'team_member_id', :null => false

      t.timestamps null: false
    end

    add_index :team_memberships, :team_id
    add_index :team_memberships, :team_member_id
    add_index :team_memberships, [:team_id, :team_member_id], unique: true
  end
end

class RemoveMissionAndSlotsFromTeams < ActiveRecord::Migration
  def change
    remove_column :teams, :mission, :text
    remove_column :teams, :slots, :integer
  end
end

class AddSlotsToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :slots, :integer
    remove_column :teams, :number_of_members
    remove_column :teams, :number_of_projects

    change_table :teams do |t|
      t.belongs_to :project, index: true
    end
  end
end

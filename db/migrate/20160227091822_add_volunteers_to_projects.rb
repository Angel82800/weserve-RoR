class AddVolunteersToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :volunteers, :integer, default: 0
  end
end

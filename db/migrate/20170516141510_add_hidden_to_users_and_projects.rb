class AddHiddenToUsersAndProjects < ActiveRecord::Migration
  def change
    add_column :users, :hidden, :boolean, :default => false
    add_column :projects, :hidden, :boolean, :default => false
  end
end

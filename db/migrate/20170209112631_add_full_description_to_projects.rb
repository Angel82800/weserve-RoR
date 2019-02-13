class AddFullDescriptionToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :full_description, :text
  end
end

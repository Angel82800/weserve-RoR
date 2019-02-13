class AddRequestDescriptionToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :request_description, :text
  end
end

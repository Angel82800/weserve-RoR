class AddVideoUrlToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :video_id, :string
  end
end

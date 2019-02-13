class DropFavoriteProjectsTable < ActiveRecord::Migration
  def change
     drop_table :favorite_projects
  end
end

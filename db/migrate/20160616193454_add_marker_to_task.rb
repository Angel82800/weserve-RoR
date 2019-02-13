class AddMarkerToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :marker, :boolean, :default=>false
  end
end

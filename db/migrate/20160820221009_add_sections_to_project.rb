class AddSectionsToProject < ActiveRecord::Migration
  def change
    add_column :projects, :section1, :text
    add_column :projects, :section2, :text
  end
end

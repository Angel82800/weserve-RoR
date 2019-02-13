class AddSlugToProject < ActiveRecord::Migration
  def up
    add_column :projects, :slug, :string
    Project.find_each(&:save) if Project.included_modules.include?(FriendlyId::Model)
  end

  def down
    remove_column :projects, :slug, :string
  end
end

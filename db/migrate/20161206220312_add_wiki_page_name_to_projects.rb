class AddWikiPageNameToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :wiki_page_name, :string
  end
end

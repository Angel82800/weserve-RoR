class AddInstitutionAttributesToProjects < ActiveRecord::Migration
  def change
  	add_column :projects, :institution_name, :string
  	add_column :projects, :institution_logo, :string
  	add_column :projects, :institution_description, :text
  end
end

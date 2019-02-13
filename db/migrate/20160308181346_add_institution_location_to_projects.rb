class AddInstitutionLocationToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :institution_location, :string
  end
end

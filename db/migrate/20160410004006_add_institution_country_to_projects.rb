class AddInstitutionCountryToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :institution_country, :string
  end
end

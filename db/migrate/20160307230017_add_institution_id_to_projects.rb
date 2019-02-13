class AddInstitutionIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :institution_id, :integer
  end
end

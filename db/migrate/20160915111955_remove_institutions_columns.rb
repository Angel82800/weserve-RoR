class RemoveInstitutionsColumns < ActiveRecord::Migration
  def change
    remove_column :projects, :institution_id
    remove_column :projects, :institution_name
    remove_column :projects, :institution_logo
    remove_column :projects, :institution_description
    remove_column :projects, :institution_location
    remove_column :projects, :institution_country
    remove_column :users, :institution_id
  end
end

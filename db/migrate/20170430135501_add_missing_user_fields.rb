class AddMissingUserFields < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :state, :string
    add_column :users, :skype_id, :string
    add_column :users, :facebook_id, :string
    add_column :users, :linkedin_id, :string
    add_column :users, :twitter_id, :string
  end
end

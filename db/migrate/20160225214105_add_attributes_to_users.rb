class AddAttributesToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :country, :string
  	add_column :users, :description, :text
  	add_column :users, :picture, :string
  	add_column :users, :company, :string

  end
end

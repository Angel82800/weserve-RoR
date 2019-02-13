class AddAttributesTo < ActiveRecord::Migration
  def change
  	add_column :users, :first_link, :string
  	add_column :users, :second_link, :string
  	add_column :users, :third_link, :string
  	add_column :users, :city, :string
  end
end

class AddFourthLinkToUsers < ActiveRecord::Migration
  def change
    add_column :users, :fourth_link, :string
  end
end

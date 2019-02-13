class AddColomTouser < ActiveRecord::Migration
  def change
    add_column :users, :test_id, :integer
  end
end

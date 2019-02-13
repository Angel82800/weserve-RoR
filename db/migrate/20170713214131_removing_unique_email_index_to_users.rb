class RemovingUniqueEmailIndexToUsers < ActiveRecord::Migration
  def change
    remove_index :users, :email
    add_index :users, :email, using: :btree
  end
end

class AddConfirmedAtToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :confirmed_at, :datetime
  end
end

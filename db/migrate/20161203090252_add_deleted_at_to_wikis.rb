class AddDeletedAtToWikis < ActiveRecord::Migration
  def change
    add_column :wikis, :deleted_at, :datetime
    add_index :wikis, :deleted_at
  end
end

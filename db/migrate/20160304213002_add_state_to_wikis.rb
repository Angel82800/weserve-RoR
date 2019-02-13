class AddStateToWikis < ActiveRecord::Migration
  def change
    add_column :wikis, :state, :string
  end
end

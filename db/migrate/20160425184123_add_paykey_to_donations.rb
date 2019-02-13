class AddPaykeyToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :PAYKEY, :string
  end
end

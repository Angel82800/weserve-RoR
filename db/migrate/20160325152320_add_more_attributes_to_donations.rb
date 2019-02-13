class AddMoreAttributesToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :paypal_email, :string
  end
end

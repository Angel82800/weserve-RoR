class DropStripePayments < ActiveRecord::Migration
  def change
  	drop_table :stripe_payments
  end
end

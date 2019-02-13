class DeleteAtToStripePayment < ActiveRecord::Migration
  def change
    add_column :stripe_payments, :deleted_at, :datetime
    add_index :stripe_payments, :deleted_at
  end
end

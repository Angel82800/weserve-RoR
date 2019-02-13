class AddTxInternalIdToStripePayments < ActiveRecord::Migration
  def change
    add_column :stripe_payments, :tx_internal_id, :string
  end
end

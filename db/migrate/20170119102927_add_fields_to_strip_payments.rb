class AddFieldsToStripPayments < ActiveRecord::Migration
  def change
    add_reference :stripe_payments, :user, index: true, foreign_key: true
    add_column :stripe_payments, :stripe_token, :string
    add_column :stripe_payments, :amount_in_satoshi, :string
    add_column :stripe_payments, :stripe_response_id, :string
    add_column :stripe_payments, :balance_transaction, :string
    add_column :stripe_payments, :paid, :boolean
    add_column :stripe_payments, :refund_url, :string
    add_column :stripe_payments, :status, :string
    add_column :stripe_payments, :seller_message, :string
  end
end

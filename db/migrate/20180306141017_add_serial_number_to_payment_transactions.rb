class AddSerialNumberToPaymentTransactions < ActiveRecord::Migration
  def change
    add_column :payment_transactions, :serial_number, :string
  end
end

class ChangeDataTypeOfPaymentTransactions < ActiveRecord::Migration
  def change
    change_column :payment_transactions, :status, "integer USING NULLIF(status, '')::int"
    change_column :payment_transactions, :payment_type, "integer USING NULLIF(payment_type, '')::int"
  end
end
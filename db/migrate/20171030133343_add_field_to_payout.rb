class AddFieldToPayout < ActiveRecord::Migration
  def change
    add_column :payout_transactions, :payout_id, :string
  end
end
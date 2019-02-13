class AddSourceTypeToTransactionHistories < ActiveRecord::Migration
  def change
    add_column :transaction_histories, :source_type, :string
  end
end

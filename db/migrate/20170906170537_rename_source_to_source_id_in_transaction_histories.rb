class RenameSourceToSourceIdInTransactionHistories < ActiveRecord::Migration
  def change
    rename_column :transaction_histories, :source, :source_id
  end
end

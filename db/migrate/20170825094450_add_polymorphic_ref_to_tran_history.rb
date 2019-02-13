class AddPolymorphicRefToTranHistory < ActiveRecord::Migration
  def change
    add_reference :transaction_histories, :tran_record, polymorphic: true, index: {:name => "index_for_transaction_histroy"}
  end
end

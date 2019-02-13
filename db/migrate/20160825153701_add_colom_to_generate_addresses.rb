class AddColomToGenerateAddresses < ActiveRecord::Migration
  def change
      rename_column :generate_addresses, :address, :sender_address
      add_column :generate_addresses, :wallet_id, :string
      add_column :generate_addresses, :receiver_address, :string
      add_column :generate_addresses, :pass_phrase, :string
    end
end

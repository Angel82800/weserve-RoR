class AddLegalDocumentToPayoutDetails < ActiveRecord::Migration
  def change
    add_column :payout_details, :legal_document, :string
    add_column :payout_details, :last_4_ssn, :string
  end
end

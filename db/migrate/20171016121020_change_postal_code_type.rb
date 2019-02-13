class ChangePostalCodeType < ActiveRecord::Migration
  def up
    change_column :payout_details, :postal_code, :string
  end

  def down
    change_column :payout_details, :postal_code, :integer
  end
end

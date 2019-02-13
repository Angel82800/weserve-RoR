class CreateTaxDeduction < ActiveRecord::Migration
  def change
    create_table :tax_deductions do |t|
      t.integer :user_id
      t.string :name
      t.string :address
      t.string :postal_code
      t.string :city
      t.string :country
    end
  end
end

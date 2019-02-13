class CreatePayoutDetails < ActiveRecord::Migration
  def change
    create_table :payout_details do |t|
      t.string :country
      t.string :state
      t.string :city
      t.text :address
      t.integer :postal_code
      t.string :first_name
      t.string :last_name
      t.string :dob
      t.integer :ssn
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

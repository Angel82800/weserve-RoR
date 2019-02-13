class CreateStripePayments < ActiveRecord::Migration
  def change
    create_table :stripe_payments do |t|
      t.decimal :amount
      t.string :tx_hash
      t.references :task, index: true, foreign_key: true
      t.boolean :transferd

      t.timestamps null: false
    end
  end
end

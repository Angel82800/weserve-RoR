class CreateCreditCards < ActiveRecord::Migration
  def change
    create_table :credit_cards do |t|
      t.string :card_id
      t.integer :status
      t.string :last4
      t.references :user, index: true
      t.timestamps null: false
    end
  end
end

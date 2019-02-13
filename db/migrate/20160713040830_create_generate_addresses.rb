class CreateGenerateAddresses < ActiveRecord::Migration
  def change
    create_table :generate_addresses do |t|
      t.string   "address"
      t.boolean  "is_available"
      t.timestamps null: false
    end
  end
end

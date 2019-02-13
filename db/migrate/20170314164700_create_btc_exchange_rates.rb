class CreateBtcExchangeRates < ActiveRecord::Migration
  def change
    create_table :btc_exchange_rates do |t|
      t.decimal :rate , precision: 15, scale: 10
      t.timestamps null: false
    end
  end
end

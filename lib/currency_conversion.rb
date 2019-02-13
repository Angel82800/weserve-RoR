module CurrencyConversion
  def self.usd_to_cents(balance = 0)
    (100 * balance.to_f).to_i
  end

  def self.cents_to_usd(amount = 0)
    amount.to_i / 100.0
  end
end

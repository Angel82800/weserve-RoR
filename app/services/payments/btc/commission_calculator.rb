#currently we are not using commission_in_cents, commission_in_usd methods
module Payments::BTC
  class CommissionCalculator
    attr_reader :usd_amount

    DEFAULT_WESERVE_FEE = 0
    weserve_fee = ENV['weserve_service_fee'].present? ? ENV['weserve_service_fee'] : DEFAULT_WESERVE_FEE
    STRIPE_FEE            = BigDecimal.new("0.029")
    WESERVE_FEE           = weserve_fee
    CONVERSION_FEE        = BigDecimal.new("0.0149")
    STRIPE_ADDITIONAL_FEE = BigDecimal.new("0.3")

    def initialize(usd_amount)
      @usd_amount = BigDecimal.new(usd_amount.to_s)
    end

    def commission_in_usd
      stripe_fee = (usd_amount * STRIPE_FEE + STRIPE_ADDITIONAL_FEE).round(2)
      usd_amount_after_stripe_fee = usd_amount - stripe_fee

      weserve_fee = (usd_amount_after_stripe_fee * BigDecimal.new(WESERVE_FEE)).round(2)
      usd_amount_after_weserve_fee = usd_amount_after_stripe_fee - weserve_fee

      conversion_fee = (usd_amount_after_weserve_fee * CONVERSION_FEE).round(2)
      usd_amount_after_conversion_fee = usd_amount_after_weserve_fee - conversion_fee

      (usd_amount - usd_amount_after_conversion_fee).to_f
    end

    def commission_in_cents
      commission_in_usd * 100.0
    end
  end
end

class Payments::Base::Base
  class Configuration
    attr_reader :weserve_fee             # commission which weserve takes

    def initialize(weserve_fee:)
      # validations
      raise ArgumentError, "weserve_fee cannot be empty" if weserve_fee.blank?

      # fees configuration
      @weserve_fee = BigDecimal.new(weserve_fee)
    end
  end

  class << self
    delegate :weserve_fee, to: :configuration

    def configuration
      @configuration ||= init_configuration
    end

    private
    def init_configuration
      Configuration.new(
        weserve_fee: Payments::BTC::CommissionCalculator::WESERVE_FEE
      )
    end
  end
end

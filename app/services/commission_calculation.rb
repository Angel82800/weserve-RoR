# write now we are using it for testing purpost sooner or later we will modify it
#currently we are not using commission_in_cents method and constants
class CommissionCalculation
  attr_reader :cents_amount
  STRIPE_FEE            = 2.9
  WESERVE_FEE           = 5
  CONVERSION_FEE        = 1.49
  STRIPE_ADDITIONAL_FEE = 30

  def initialize(cents_amount, user)
    @cents_amount = cents_amount
    @user = user
  end

  def commission_in_cents
    0
  end

  def amount_after_fee
    @cents_amount - get_stripe_processing_fee
  end

  def get_stripe_processing_fee
    @user.payment_transactions.last.try(:processing_fee) || 0
  end

end
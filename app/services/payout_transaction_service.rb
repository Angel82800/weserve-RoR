class PayoutTransactionService
  PAYOUT_FEE = 5

  def initialize(options = {})
    @user = options[:user]
    @payout_provider = options[:payout_provider]
    @target_account = options[:target_account]
    @transaction_id = options[:transaction_id]
    @status = options[:status]
    @amount = options[:amount]
    @fee = options[:fee]
    @payout_id = options[:payout_id]
  end

  def perform!
    PayoutTransaction.create(
      user: @user,
      payout_provider: @payout_provider,
      target_account: @target_account,
      transaction_id: @transaction_id,
      status: @status,
      amount: @amount,
      fee: @fee,
      payout_id: @payout_id
    )
  end

  class << self
    def create_payout_history(options = {})
      return false if options[:user].nil?
      new(options).perform!
    end

    def get_fee_from_payout(amount)
      without_fee = (amount * ((100 - PAYOUT_FEE)/100.0)).to_i
      fee = amount - without_fee

      [ without_fee, fee ]
    end
  end
end

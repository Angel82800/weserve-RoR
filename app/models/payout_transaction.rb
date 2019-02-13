class PayoutTransaction < ActiveRecord::Base
  enum payout_provider: [:stripe, :coinbase]
  enum status: [:paid, :pending, :in_transit, :canceled, :failed]

  belongs_to :user

  def self.payout_status(payout_status)
    case payout_status
    when 'paid'
      PayoutTransaction.statuses["paid"]
    when 'pending'
      PayoutTransaction.statuses["pending"]
    when 'in_transit'
      PayoutTransaction.statuses["in_transit"]
    when 'canceled'
      PayoutTransaction.statuses["canceled"]
    when 'failed'
      PayoutTransaction.statuses["failed"]
    end
  end

  def display_transaction
    "Withdrawal with status: #{status}"
  end
end

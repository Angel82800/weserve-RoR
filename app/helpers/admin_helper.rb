module AdminHelper
  def platform_balance
    PayoutTransaction.where(status: PayoutTransaction.statuses['paid']).sum(:fee)
  end
end

class UpdateHoldBalancesJob
  def perform
    hold_balance = HoldBalance.get_older_record
    hold_balance.try(:each) do |bal|
      bal.user.balance.increment!(:amount, bal.amount)
      bal.destroy
      NotificationMailer.fund_available(bal.user.id, CurrencyConversion.cents_to_usd(bal.amount)).deliver_later
    end
  end
end
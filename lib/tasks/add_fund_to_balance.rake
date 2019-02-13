namespace :balances do
  desc "add fund from hold balance to real balance"
  task add_fund_to_balance: :environment do
    hold_balance = HoldBalance.get_older_record
    hold_balance.try(:each) do |bal|
      bal.user.balance.increment!(:amount, bal.amount)
      bal.destroy
      NotificationMailer.fund_available(bal.user.id, CurrencyConversion.cents_to_usd(bal.amount)).deliver_later
    end
  end
end
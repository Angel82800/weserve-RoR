namespace :balance do
  desc "create balance for existing user"
  task create_balance: :environment do
    without_balance = User.includes(:balance).where(balances: { id: nil })
    if without_balance
      without_balance.each do |user|
        user.create_balance
      end
    end
  end
end
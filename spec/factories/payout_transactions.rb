FactoryGirl.define do
  factory :payout_transaction do
    user nil
    payout_provider 1
    target_account 1
    transaction_id 1
    status 1
    amount 1
    fee 1
  end
end

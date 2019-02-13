FactoryGirl.define do
  factory :transaction_history do
    entity 1
    entity_balance 1
    operation_type ""
    amount 1.5
    source { create(:user, :confirmed_user) }
    tran_record { create(:user, :confirmed_user) }
  end
end

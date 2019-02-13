FactoryGirl.define do
  factory :chat_session do
    requester { create(:user, :confirmed_user) }
    receiver { create(:user, :confirmed_user) }
  end
end

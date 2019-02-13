FactoryGirl.define do
  factory :change_leader_invitation do
    new_leader { 'test@mail.com' }
    sent_at { 2.days.ago }
    association :project, factory: :project
  end
end

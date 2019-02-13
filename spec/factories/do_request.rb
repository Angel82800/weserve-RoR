FactoryGirl.define do
  factory :do_request, class: DoRequest do
    association :user, :confirmed_user, factory: :user
    association :project, factory: :project, picture: nil
    association :task
    application "Test application"
    state { 'pending' }
  end
end

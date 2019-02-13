FactoryGirl.define do
  factory :notification, class: Notification do
    association :user, factory: :user
    association :source_model, factory: :project
  end
end

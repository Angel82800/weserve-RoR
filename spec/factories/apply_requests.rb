FactoryGirl.define do
  factory :lead_editor_request, class: ApplyRequest do
    association :user, :confirmed_user, factory: :user
    association :project, factory: :project
    request_type :Lead_Editor
  end

  factory :coordinator_request, class: ApplyRequest do
    association :user, :confirmed_user, factory: :user
    association :project, factory: :project
    request_type :Coordinator
  end
end

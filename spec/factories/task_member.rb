FactoryGirl.define do
  factory :task_member, class: TaskMember do
    task              { build(:task) }
    team_membership   { build(:team_membership) }
  end
end

FactoryGirl.define do
  factory :team_membership, class: TeamMembership do
    role        { 'leader' }
    team        { build(:team) }
    team_member { build(:user) }

    trait :teammate do
      role    { 'teammate' }
    end

    trait :lead_editor do
      role    { 'lead_editor' }
    end

    trait :coordinator do
      role    { 'coordinator' }
    end

    trait :task do
      transient do
        task { create(:task) }
      end

      after(:create) do |team_membership, evaluator|
        create(:task_member, task: evaluator.task, team_membership: team_membership)
      end
    end
  end
end

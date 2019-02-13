FactoryGirl.define do
  factory :activity do
    user        { build(:user) }
    action      { 'created' }
    targetable  { build(:task) }

    trait :task_comment do
      transient do
        task      { build(:task) }
      end

      targetable   { build(:task_comment, task: task) }
    end

    trait :team_membership do
      transient do
        task      { build(:task) }
      end

      action       { 'deleted' }
      targetable   { create(:team_membership, :task, task: task) }
    end
  end
end

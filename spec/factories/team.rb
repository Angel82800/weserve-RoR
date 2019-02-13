FactoryGirl.define do
  factory :team, class: Team do
    project   { build(:project) }

    after(:create) do |team|
      create(:team_membership, team: team)
    end
  end
end

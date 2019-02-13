FactoryGirl.define do
  factory :project do
    sequence(:title) { |n| "test_project#{n}" }
    sequence(:slug) { |n| "test_project#{n}" }
    sequence(:short_description) { |n| "short_description#{n}" }
    sequence(:country) { |n| "test_country#{n}" }
    sequence(:wiki_page_name) { |n| "wiki_page_name#{n}" }
    picture { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'photo.png'), 'image/png') }
    user { build(:user, :confirmed_user) }
    state "pending"

    after(:create) do |project|
      project_team = project.create_team(name: "Team#{project.id}")
      TeamMembership.create(team_member_id: project.user.id, team_id: project_team.id, role: 1)
    end
  end

  factory :base_project, class: Project do
    title Faker::Lorem.words(4)
    state 'pending'
    short_description Faker::Lorem.words(4)
    association :user, factory: :user
    wiki_page_name Faker::Lorem.words(3)
    picture { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'photo.png'), 'image/png') }
  end
end

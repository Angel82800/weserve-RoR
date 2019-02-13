FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "test_user#{n}@example.com"}
    password 'secretadmin0password'
    sequence(:username) { |n| "username#{n}"}
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    trait :confirmed_user do
      confirmed_at DateTime.now
    end

    trait :with_balance do
      transient do
        amount 0
      end  
      after(:create) do |user, evaluator|
        user.balance.update_attribute(:amount, evaluator.amount)
      end
    end

    trait :with_password_confirmation do
      password_confirmation 'secretadmin0password'
    end

    trait :with_social_provider do
      provider 'facebook'
      uid 'ABC012346789'
    end

    trait :with_broken_social_provider do
      provider 'facebook'
      uid ''
    end
  end
end

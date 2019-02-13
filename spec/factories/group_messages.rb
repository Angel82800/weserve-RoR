FactoryGirl.define do
  factory :group_message do
    message Faker::Lorem.paragraph
    # attachment
    chatroom
    user
  end
end

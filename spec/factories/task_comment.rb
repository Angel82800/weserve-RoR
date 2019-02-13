FactoryGirl.define do
  factory :task_comment do
    sequence(:body) { |n| "body #{n}" }
  end

  trait :with_attachment do
    attachment do
      File.open(File.join(Rails.root, 'spec', 'fixtures', 'photo.png'))
    end
  end
end

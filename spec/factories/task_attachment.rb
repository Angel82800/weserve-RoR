FactoryGirl.define do
  factory :task_attachment do
    task
    attachment do
      File.open(File.join(Rails.root, 'spec', 'fixtures', 'photo.png'))
    end
  end
end

class TaskReview < ActiveRecord::Base
  belongs_to :user
  belongs_to :task

  validates :rating, presence: true
  validates :rating, inclusion: { in: 1..5 }
end

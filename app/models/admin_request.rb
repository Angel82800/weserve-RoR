class AdminRequest < ActiveRecord::Base
  enum status: [:pending, :accepted, :rejected]

  belongs_to :project
  belongs_to :user

  validates :user, presence: true
  validates :project, presence: true
end

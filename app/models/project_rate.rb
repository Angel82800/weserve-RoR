class ProjectRate < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  validates :rate, presence: true, numericality: { greater_than: 0 }
  validates :user_id, uniqueness: { scope: [:project_id] }
end

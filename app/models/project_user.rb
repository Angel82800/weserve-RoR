class ProjectUser  < ActiveRecord::Base
  belongs_to :project
  belongs_to :follower, class_name: 'User', foreign_key: :user_id
  belongs_to :coordinator, class_name: 'User', foreign_key: :user_id
  belongs_to :lead_editor, class_name: 'User', foreign_key: :user_id
  belongs_to :user
  
  validates :project_id, :user_id, presence: true
  validates :user_id, uniqueness: { scope: [:project_id], message: 'already followed project' }
end

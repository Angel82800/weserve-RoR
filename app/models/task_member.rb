class TaskMember < ActiveRecord::Base
  belongs_to :team_membership
  belongs_to :task

  validates_uniqueness_of :task_id, :scope => :team_membership_id
end

class Team < ActiveRecord::Base
  belongs_to :project
  has_many :team_memberships, dependent: :destroy
  has_many :team_members, :through => :team_memberships, class_name: 'User', source: 'team_member'

  def leader_and_coordinator_ids
    team_memberships.where(role: [TeamMembership.roles[:leader],TeamMembership.roles[:coordinator]]).collect(&:team_member_id)
  end
end

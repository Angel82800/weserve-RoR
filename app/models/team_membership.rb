class TeamMembership < ActiveRecord::Base
  ROLES = { teammate: 0, leader: 1,  lead_editor: 2, coordinator: 3 }
  COORDINATOR_ID = ROLES[:coordinator].freeze
  LEAD_EDITOR_ID = ROLES[:lead_editor].freeze
  TEAM_MATE_ID   = ROLES[:teammate].freeze

  enum role: ROLES

  belongs_to :team
  belongs_to :team_member, foreign_key: 'team_member_id', class_name: 'User'
  has_many :tasks, through: :task_members
  has_many :task_members
  after_save :add_follower

  # Paranoia delete
  acts_as_paranoid

  scope :find_team_members, ->(team_member_id) { where team_member_id: team_member_id }

  def self.get_roles
    humanize_roles = []
    roles.each do |key, value|
      if value != roles[:leader]
        humanize_roles << [key, key.humanize]
      end
    end
    humanize_roles
  end

  private
  def auto_follow_roles
    [TeamMembership.roles[:leader], TeamMembership.roles[:coordinator], TeamMembership.roles[:lead_editor]]
  end

  def add_follower
    team.project.followers << team_member if !team.project.followers.ids.include?(team_member.id) && auto_follow_roles.include?(TeamMembership.roles[role])
  end
end

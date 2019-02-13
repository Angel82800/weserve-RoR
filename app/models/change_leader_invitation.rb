class ChangeLeaderInvitation < ActiveRecord::Base
  belongs_to :project

  scope :pending, -> { where("accepted_at IS NULL and rejected_at IS NULL") }

  def is_valid?
    accepted_at.nil? && rejected_at.nil?
  end

  def accept!

    project = self.project
    new_leader = User.where(:email => self.new_leader).first
    old_leader = project.user

    # project.update(user_id: new_leader.id)

    project.revoke_permissions old_leader.username
    project.grant_permissions new_leader.username

    project.team.team_memberships.find_by_team_member_id(new_leader.id).update(role: 1)
    project.team.team_memberships.find_by_team_member_id(old_leader.id).update(role: 0)

    self.update(accepted_at: Time.current)
  end

  def reject!
    self.update(rejected_at: Time.current)
  end
end

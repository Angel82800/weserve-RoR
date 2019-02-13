class TeamMembershipObserver < ActiveRecord::Observer

  def after_create(team_membership)
    NotificationsService.notify_team_member_about_admin_permissions(team_membership) if team_membership.coordinator?
  end

  def after_update(team_membership)
    if (team_membership.role_changed? && team_membership.coordinator?)
      NotificationsService.notify_team_member_about_admin_permissions(team_membership)
    elsif (team_membership.role_changed? && team_membership.role_was == "leader")
      NotificationsService.notify_about_lost_admin_permissions(team_membership)
    end
  end

  def after_destroy(team_membership)
    if team_membership.coordinator?
      NotificationsService.notify_about_lost_admin_permissions(team_membership)
    end
  end

end
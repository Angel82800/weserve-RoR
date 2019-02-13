class NotificationsService
  def self.notify_team_member_about_admin_permissions(team_membership)
    self.notify_about_admin_permissions(team_membership.team.project, team_membership.team_member)
  end

  def self.notify_about_admin_permissions(project, user)
    self.create_notification(project, user, Notification.actions[:became_project_admin])
  end

  def self.notify_about_lost_admin_permissions(team_membership)
    self.create_notification(team_membership.team.project, team_membership.team_member, Notification.actions[:lost_project_admin_status])
  end

  def self.notify_about_project_creation(project)
    self.create_notification(project, project.user, Notification.actions[:created_project], nil, "operatable")
  end

  def self.notify_about_project_update(project)
    self.create_notification(project, project.user, Notification.actions[:updated_project])
    project.project_users.each do |member|
      self.create_notification(project, member.follower, Notification.actions[:updated_project])
    end
  end

  def self.notify_about_admin_request(admin_request)
    self.create_notification(admin_request, admin_request.project.user, Notification.actions[:admin_request], admin_request.user, "operatable")
  end

  def self.notify_about_reject_admin_request(admin_request, origin_user)
    self.create_notification(admin_request, admin_request.user, Notification.actions[:reject_admin_request], origin_user)
  end

  def self.notify_about_accept_admin_request(admin_request, origin_user)
    self.create_notification(admin_request, admin_request.user, Notification.actions[:accept_admin_request], origin_user)
  end

  def self.notify_about_apply_request(apply_request)
    self.create_notification(apply_request, apply_request.project.user, Notification.actions[:apply_request], apply_request.user, "operatable")
  end

  def self.notify_about_reject_admin_request(admin_request, origin_user)
    self.create_notification(apply_request, apply_request.user, Notification.actions[:reject_apply_request], origin_user)
  end

  def self.notify_about_accept_admin_request(admin_request, origin_user)
    self.create_notification(apply_request, apply_request.user, Notification.actions[:accept_apply_request], origin_user)
  end

  def self.notify_about_suggested_task(task)
    self.create_notification(task, task.project.user, Notification.actions[:suggested_task], task.user, "operatable")
    task.project.followers.each do |user|
      self.create_notification(task, user, Notification.actions[:suggested_task], task.user) unless user.is_admin_for? task.project
    end
  end

  def self.notify_about_rejected_task(task)
    self.create_notification(task, task.project.user, Notification.actions[:rejected_task], task.user, "operatable")
  end

  def self.notify_about_pending_do_request(do_request)
    self.create_notification(do_request, do_request.task.project.user, Notification.actions[:pending_do_request], do_request.user, "operatable")
  end

  def self.notify_about_leader_change(user, new_leader, project)
    self.create_notification(project, user, Notification.actions[:leader_change], new_leader, "operatable")
  end

  def self.notify_about_change_leader_invitation(user, new_leader, project)
    self.create_notification(project, new_leader, Notification.actions[:change_leader_invitation], user, "operatable")
    self.create_notification(project, user, Notification.actions[:change_leader_invitation_sent], new_leader)
  end

  def self.notify_about_follow_project(project, followed_user)
    self.create_notification(project, project.user, Notification.actions[:follow_project], followed_user)
    self.create_notification(project, followed_user, Notification.actions[:follow_project])
  end

  def self.notify_about_accept_task(task, user)
    self.create_notification(task, user, Notification.actions[:accept_task])
  end

  private

  def self.create_notification(model, user, action, origin_user = nil, type="text")
    Notification.create(
        user: user,
        source_model: model,
        origin_user: origin_user,
        action: action,
        action_type: type
    )
  end

  def self.create_notification_by_ids(model_id, model_type, user_id, action)
    Notification.create(
        user_id: user_id,
        source_model_id: model_id,
        source_model_type: model_type,
        action: action
    )
  end
end

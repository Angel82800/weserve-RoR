class AdminInvitationObserver < ActiveRecord::Observer

  def after_create(admin_invitation)
    NotificationsService.notify_about_admin_invitation(admin_invitation, admin_invitation.sender)
  end

  def after_update(admin_invitation)
    if admin_invitation.status_changed?
      if admin_invitation.accepted?
        NotificationsService.notify_about_admin_permissions(admin_invitation.project, admin_invitation.user)
        NotificationsService.notify_about_accept_admin_invitation(admin_invitation, admin_invitation.project.user, admin_invitation.user)
      elsif admin_invitation.rejected?
        NotificationsService.notify_about_reject_admin_invitation(admin_invitation, admin_invitation.project.user, admin_invitation.user)
      end
    end
  end

end
class AdminRequestObserver < ActiveRecord::Observer

  def after_create(admin_request)
    NotificationsService.notify_about_admin_request(admin_request)
  end

  def after_update(admin_request)
    if admin_request.status_changed?
      if admin_request.accepted?
        NotificationsService.notify_about_admin_permissions(admin_request.project, admin_request.user)
        NotificationsService.notify_about_accept_admin_request(admin_request, admin_request.project.user)
      elsif admin_request.rejected?
        NotificationsService.notify_about_reject_admin_request(admin_request, admin_request.project.user)
      end
    end
  end

end
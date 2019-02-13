class ApplyRequestObserver < ActiveRecord::Observer
  def after_create(apply_request)
    NotificationsService.notify_about_apply_request(apply_request)
  end

  def after_update(apply_request)
    # if apply_request.status_changed?
    #   if apply_request.accepted?
    #     NotificationsService.notify_about_apply_permissions(apply_request.project, apply_request.user)
    #     NotificationsService.notify_about_accept_apply_request(apply_request, apply_request.project.user)
    #   elsif apply_request.rejected?
    #     NotificationsService.notify_about_reject_apply_request(apply_request, apply_request.project.user)
    #   end
    # end
  end
end
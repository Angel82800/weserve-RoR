class DoRequestObserver < ActiveRecord::Observer

  def after_save(do_request)
    if (do_request.pending?)
      NotificationsService.notify_about_pending_do_request(do_request)
    end
  end

end
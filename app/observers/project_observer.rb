class ProjectObserver < ActiveRecord::Observer
  def after_create(project)
    NotificationsService.notify_about_project_creation(project)
  end

  def after_update(project)
    NotificationsService.notify_about_project_update(project)
  end
end

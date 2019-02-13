class TaskObserver < ActiveRecord::Observer
  def after_create(task)
    if (task.suggested_task?)
      NotificationsService.notify_about_suggested_task(task)
      
      NotificationMailer.suggest_task(task.project.user, task).deliver_later
      (task.project.followers - [task.user]).each do |user|
        NotificationMailer.suggest_task(user, task).deliver_later
      end
    end
  end
end

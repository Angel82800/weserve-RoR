module SendNotification
  extend ActiveSupport::Concern
  included do
    def send_notification_task_started
      self.interested_users.each do |user|
        NotificationMailer.task_started(acting_user: User.current_user, task: self, receiver: user).deliver_later
      end
    end
  end

end
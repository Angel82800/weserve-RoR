class Balance < ActiveRecord::Base
  belongs_to :user
  belongs_to :task
  after_save :update_state_task

  def parent
    self.user || self.task
  end

  def funded
    raise StandardError, 'User model not supported funded balance' if self.parent.class == User
    attributes['funded']
  end

  def amount_in_dollars
    CurrencyConversion.cents_to_usd(amount)
  end

  private
  def update_state_task
    task.send_notification_task_started if task&.fully_funded_and_enough_teammembers? && task&.start_doing!
  end
end

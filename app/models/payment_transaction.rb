class PaymentTransaction < ActiveRecord::Base
  enum status: [:failed ,:pending, :completed]
  enum payment_type: [:card , :bank, :btc]

  belongs_to :task
  belongs_to :user

  # Custom callbacks
  after_save :add_donor_to_project

  # Instance methods
  def display_transaction
    "Payment with #{payment_type}. Status: #{status}"
  end

  # when user funded to task - he becomes a 'donor'
  def add_donor_to_project
    return unless task
    return unless status == self.class.statuses.key(self.class.statuses[:completed])
    BadgeService.assign_donor(task.project, user)
  end
end

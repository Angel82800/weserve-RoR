class CustomAccount < ActiveRecord::Base
  enum status: [:unverified, :pending, :verified]

  belongs_to :user

  def self.custom_acc_status(custom_acc_status)
    case custom_acc_status
    when 'unverified'
      CustomAccount.statuses['unverified']
    when 'pending'
      CustomAccount.statuses['pending']
    when 'verified'
      CustomAccount.statuses['verified']
    end
  end
end

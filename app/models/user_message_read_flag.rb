class UserMessageReadFlag< ActiveRecord::Base
  belongs_to :user
  belongs_to :group_message

  scope :unread, -> { where(read_status: false) }
  scope :for_user_count, -> (user) { (where(user_id: user.id)).count > 0 ? "("+(where(user_id: user.id)).count.to_s+")" : "" }

  def mark_as_read
    self.update_attribute(:read_status,true)
  end
end

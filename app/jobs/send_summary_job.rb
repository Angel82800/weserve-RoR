class SendSummaryJob < ActiveJob::Base
  queue_as :default

  def perform()
    User.all.each do |user|
      unread_messages = user.user_message_read_flags.unread
      if unread_messages.size > 0
        ChatMailer.send_summary(user.id).deliver_later
      end
    end
  end
end

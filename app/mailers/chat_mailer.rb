class ChatMailer < ApplicationMailer
  include ActionView::Helpers::TextHelper
  def invite_receiver(requester_id, receiver_id)
    requester = User.find(requester_id)
    receiver = User.find(receiver_id)
    mailjet_notification(receiver, requester: requester)
  end

  def send_summary user_id
    user = User.find(user_id)

    messages = []
    user.user_message_read_flags.unread.limit(3).each do |msg|
      messages << truncate(msg.group_message.message, length: 160)
    end

    mailjet_notification(user, additional_params: { "Summaries" => messages })
  end
end

# Preview all emails at http://localhost:3000/rails/mailers/chat_mailer
class ChatMailerPreview < ActionMailer::Preview
  def invite_receiver
    ChatMailer.invite_receiver(User.first.id, User.last.id)
  end
end

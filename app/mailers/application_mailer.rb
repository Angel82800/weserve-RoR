class ApplicationMailer < ActionMailer::Base
  include MailerHelper

  def mailjet_mail(to_email, message_params)
    mailjet_message_params = prep_mailjet_options(message_params)
    mail(
      to: to_email,
      subject: '',
      delivery_method_options: mailjet_message_params,
      body: '',
      )
  end

  default from: ENV['weserve_from_email']
end

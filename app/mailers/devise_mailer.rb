class DeviseMailer < Devise::Mailer
  include Devise::Controllers::UrlHelpers
  include MailerHelper
  def confirmation_instructions(record, token, _opts={})
    message_params = {
      "ConfirmationUrl" => confirmation_url(record, confirmation_token: token)
    }
    mailjet_notification(record, additional_params: message_params)
  end

  def reset_password_instructions(record, token, _opts={})
    message_params = {
      "ResetPasswordUrl" => edit_password_url(record, reset_password_token: token)
    }
    mailjet_notification(record, additional_params: message_params)
  end

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

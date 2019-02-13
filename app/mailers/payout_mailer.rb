class PayoutMailer < ApplicationMailer

  def request_withdrawal(amount, receiver)
    amount = CurrencyConversion.cents_to_usd(amount)
    additional_params = { "Amount" => amount, "CurrencySymbol" => currency_symbol }
    mailjet_notification(receiver, additional_params: additional_params)
  end

  def finished_withdrawal(amount, receiver, status)
    amount = CurrencyConversion.cents_to_usd(amount)

    I18n.with_locale(user_locale(receiver)) do
      template_id =
        case status
        when 'paid'
          t('.paid.mailjet_template_id')
        when 'canceled'
          t('.canceled.mailjet_template_id')
        when 'failed'
          t('.failed.mailjet_template_id')
        when 'in_transit'
          t('.in_transit.mailjet_template_id')
        end

      message_params = {
        "TemplateID" => template_id,
        "Variables" => {
          "ReceiverName" => receiver.display_name,
          "Amount" => amount,
          "CurrencySymbol" => currency_symbol,
        }
      }
      mailjet_mail(receiver.email, message_params)
    end
  end
end

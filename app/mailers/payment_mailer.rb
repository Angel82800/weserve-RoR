class PaymentMailer < ApplicationMailer

  def fund_task(payer:, task:, receiver:, amount:)
    amount = CurrencyConversion.cents_to_usd(amount)
    additional_params = {
      "PayerName" => payer.display_name,
      "Amount" => amount,
      "CurrencySymbol" => currency_symbol,
    }
    mailjet_notification(receiver, task: task, exclude: [:project], additional_params: additional_params)
  end

  def fully_funded_task(task:, receiver:)
    mailjet_notification(receiver, task: task, project: task.project)
  end

  def tax_deduction_information(payer:, task:, transaction_id:)
    @payer = payer
    @task = task
    @transaction_id = transaction_id

    I18n.with_locale(user_locale(@user)) do
      mail(to: @payer.email, subject: t('.subject'))
    end
  end
end

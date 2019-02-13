class StripeWebhooksController < ApplicationController
  require 'stripe_webhook'
  protect_from_forgery :except => :update_acc_status
  before_action :check_signature, only: [:update_acc_status]

  def check_signature
    return false if ENV['endpoint_secret'].blank?
    endpoint_secret = ENV['endpoint_secret']
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    begin
      StripeWebhook::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue StandardError => e
      render json: { error: e.message, status: 400}, status: 400 and return
    end
  end

  def update_acc_status
    case params['type']
      when 'account.updated'
        acct_update
        render json: { success: "Account Updated Sucessfully", status: 200}, status: 200 and return
      when "payout.updated" , "payout.failed"
        payout_update
        render json: { success: 'Payout Updated Sucessfully', status: 200}, status: 200 and return
    end
    render json: { error: 'Invalid Event Type', status: 400}, status: 400
  end

  def acct_update    
    custom_acc = CustomAccount.find_by(acc_id: params['account'])
    if custom_acc.present?
      status_val = CustomAccount.custom_acc_status(params['data']['object']['legal_entity']['verification']['status'])
      previous_status = custom_acc.status
      custom_acc.update_attributes(status: status_val)
      block_withdraw
      unless CustomAccount.custom_acc_status(previous_status).eql?(status_val)
        NotificationMailer.stripe_account_update(custom_acc.user.id, previous_status).deliver_later
      end
    end
  end

  def payout_update
    payout = PayoutTransaction.where(payout_id: params["data"]["object"]["id"]).first
    status = params["data"]["object"]["status"]

    if status.eql?("canceled") || status.eql?("failed")
      res = Payments::Stripe.reverse_transfer(payout.transaction_id)

      if res[0]
        # return fee to user balance
        user_balance_with_fee = payout.fee + params["data"]["object"]["amount"]
        payout.user.increment_amount(user_balance_with_fee)
      end
    end
    unless payout.nil?
      return if payout.status.eql?(status) # return if status does not changed
      payout.update_attributes(status: PayoutTransaction.payout_status(status))
      # send notification to user about the answer
      PayoutMailer.finished_withdrawal(payout.amount, payout.user, status).deliver_later
    end
  end


  def block_withdraw
    enable_withdraw if params["data"]["object"]["payouts_enabled"] 
    if params["data"]["object"]["verification"]["due_by"].present? && params["data"]["object"]["verification"]["fields_needed"].present?
      block_or_warning_mail
    end
  end

  def block_or_warning_mail 
    if params["data"]["object"]["payouts_enabled"]
      due_date = Time.at(params["data"]["object"]["verification"]["due_by"]).strftime("%d/%m/%Y")
      NotificationMailer.send_warning_mail(get_custom_acc.user.id, due_date).deliver_later
    else
      block_and_send_mail
    end
  end  

  def block_and_send_mail
    custom_acc = get_custom_acc
    custom_acc.update_attribute(:withdrawals_enabled, false)
    NotificationMailer.block_withdraw(custom_acc.user.id).deliver_later
  end

  def enable_withdraw
    custom_acc = get_custom_acc
    custom_acc.update_attribute(:withdrawals_enabled, true)
  end

  def get_custom_acc
    CustomAccount.find_by(acc_id: params["account"])
  end
end

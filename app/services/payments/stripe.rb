# frozen_string_literal: true
# We will remove method from stripe as we find it not usefull
require 'currency_conversion'
class Payments::Stripe
  extend CurrencyConversion
  UnsupportedAmountType = Class.new(StandardError)

  def initialize(stripe_token: nil, user: nil, task: nil, card_id: nil, persist_card: false)
    if stripe_token.present?
      @stripe_token = stripe_token
    elsif user.present? && card_id.present?
      @card_id = card_id
    else
      raise(ArgumentError, 'You should provide either stripe token with/without a user or the preferred card_id with the user')
    end
    @user = user
    @task = task
    @error = nil
    @persist_card = persist_card
  end

  def direct_charge!(amount ,description = "charge user")
    return false if amount.nil? || amount < Task::MINIMUM_DONATION_SIZE
    begin
      @amount_in_cents = amount
      @description = description
      response = choose_payment_method
      amt_fee_hash = received_amount_and_stripe_fee(response.balance_transaction)
      create_logs(amt_fee_hash, amount, response)
    rescue Stripe::CardError => error
      @error = error.message
      return false
    rescue => error
      @error = error.message
      return false
    end
  end

  # provide hash to create custom account
  def self.create_custom_acc(options = {})
    return false,"Please provide all fields" if options.nil?
    begin
      acct = Stripe::Account.create({
        country: options[:country],
        type: "custom",
        payout_schedule: {interval: "manual"},
        account_token: options[:token]
      })
      LogCustomAccService.create_log(acc: acct.id, user: options[:user_id])
      return true, acct
    rescue Stripe::CardError => error
      @error = error.message
      return false, @error
    rescue => error
      @error = error.message
      return false, @error
    end
  end

  def self.external_acc_bank(options = {})
    return false, "Please provide all fields" if options.nil?
    begin
      acct = retrive_acc(options[:acct_id])
      external_account = {
        object: "bank_account",
        account_number: options[:account_number],
        country: options[:country],
        currency: options[:currency],
        account_holder_name: options[:account_holder_name],
        account_holder_type: "individual"
      }
      external_account.merge!(routing_number: options[:routing_number]) if options[:routing_number].present?

      external_acc_obj = acct[1].external_accounts.create(
        external_account: external_account
      )
      return true, external_acc_obj
    rescue Stripe::CardError => error
      return false, error.message
    rescue => error
      return false, error.message
    end
  end

  def self.delete_external_acct(options = {})
   return false, "Please provide all fields" if options.nil?
   begin
      acct = retrive_acc(options[:acct_id])
      acct[1].external_accounts.retrieve(options[:external_acct_id]).delete()
      return true, "Deleted"
    rescue Stripe::CardError => error
      return false, error.message
    rescue => error
      return false, error.message
    end
  end

  def self.retrive_acc(acc_id)
    return false, "Please provide all fields" if acc_id.nil?
   begin
    res = Stripe::Account.retrieve(acc_id)
    return true, res
    rescue StandardError => e
      return false, e.message
    end
  end

  def self.get_dob_hash(options = {})
    dob = options[:dob].split("-")
    options = options.merge("day"=>dob[2], "month"=>dob[1], "year"=>dob[0])
    options.delete(:dob)
    options
  end

  def self.file_path(id)
    if Rails.env.development? || Rails.env.test?
      PayoutDetail.find(id).legal_document.url.prepend("public")
    else
      PayoutDetail.find(id).legal_document.url
    end
  end

  def self.legal_file_upload(id)
    begin
      path = download_file_to_local(file_path(id))
      obj = Stripe::FileUpload.create(
      :purpose => 'identity_document',
      :file => File.new(path)
      )
      File.delete(path)
      return true, obj.id
    rescue StandardError => e
      return false, e.message
    end
  end

  def self.update_personal_id(options = {})
    begin
      ret_acc = retrive_acc(options[:custom_acc_id])
      ret_acc[1].account_token = options[:token]
      ret_acc[1].save
      return true, ret_acc[1]
    rescue StandardError => e
      return false, e.message
    end
  end

  def self.download_file_to_local(path)
    file_name = path.split("/")[-1]
    open("tmp/#{file_name}" , 'wb') do |file|
      file << open(path).read
    end
    "tmp/#{file_name}"
  end

  def self.transfer_to_conn_acc(options = {})
    begin
      response = Stripe::Transfer.create(:amount => options[:amount], :currency => options[:currency],
                  :destination => options[:destination])
      return true, response
    rescue Stripe::CardError, StandardError => e
      return false, e.message
    end
  end

  def self.transfer_to_external_acc(options = {})
    begin
      response = Stripe::Payout.create({
                  :amount => options[:amount],
                  :currency => options[:currency],
                  :destination => options[:card_bank_id],
                  :source_type => options[:source_type]
                  }, {:stripe_account => options[:conn_acc]})
      return true, response
    rescue Stripe::CardError, StandardError => e
      return false, e.message
    end
  end

  def self.reverse_transfer(tranfer_id)
    return false, "Please provide transafer id" if tranfer_id.nil?
    begin
      tr=Stripe::Transfer.retrieve(tranfer_id)
      tr.reversals.create
      return true, "Success"
    rescue Stripe::CardError, StandardError => e
      return false, e.message
    end
  end

  attr_reader :error, :stripe_response
  private
  attr_reader :stripe_token, :user, :task, :card_id, :persist_card, :amount_in_cents, :description
  # get received amount and stripe fee from stripe for transaction
  def received_amount_and_stripe_fee(bal_tran_id)
    return false if bal_tran_id.nil?
    begin
      balance = Stripe::BalanceTransaction.retrieve(bal_tran_id)
      stripe_fee, received_amount = balance.fee, balance.net
      return {"stripe_fee": stripe_fee, "received_amount": received_amount}
    rescue StandardError => e
      @error = e.message
      return false
    end
  end

  def create_logs(amt_fee_hash, amount, response)
    transaction = user.payment_transactions.create(
      amount: amount,
      status: get_payment_status(response),
      task: task,
      payment_type: get_payment_type,
      payment_provider: "Stripe",
      payment_token: response.id,
      processing_fee: amt_fee_hash[:stripe_fee]
    )
    transaction.update(serial_number: "#{ENV['prefix-receipt-number']}-#{Date.today.year}-#{transaction.id}")
    transaction
  end

  def get_payment_status(response)
    case response.status
    when "succeeded"
      PaymentTransaction.statuses[:completed]
    when "pending"
      PaymentTransaction.statuses[:pending]
    when "failed"
      PaymentTransaction.statuses[:failed]
    end
  end

  def get_payment_type
    PaymentTransaction.payment_types[:card]
  end

  def choose_payment_method
    stripe_customer_id = user.try(:stripe_customer_id)
    if card_id.present?
      charge_card(card_id)
    elsif persist_card.eql?("true") && stripe_customer_id.present?
      assign_and_charge_new_card
    elsif persist_card.eql?("true") && stripe_customer_id.nil?
      create_and_charge_new_customer
    else
      charge_card_without_saving # single transaction without saving card
    end
  end

  def charge_card_without_saving
    options = {
      amount: amount_in_cents,
      currency: ENV['currency'],
      source: stripe_token, # obtained with Stripe.js
      description: description }
    charge_amount!(options)
  end

  def create_and_charge_new_customer
    customer = Stripe::Customer.create(email: user.email, source: stripe_token)
    user.update_attributes(stripe_customer_id: customer.id)
    options = {
      amount: amount_in_cents,
      currency: ENV['currency'].downcase,
      customer: customer.id,
      description: description}
    charge_amount!(options)
  end

  def charge_card(card_id)
    options = {
      amount: amount_in_cents,
      currency: ENV['currency'].downcase,
      customer: user.stripe_customer_id,
      card: card_id,
      description: description}
    charge_amount!(options)
  end

  def assign_and_charge_new_card
    customer = Stripe::Customer.retrieve(user.stripe_customer_id)
    card = customer.sources.create(source: stripe_token)
    charge_card(card.id)
  end

  def charge_amount!(options)
    @stripe_response = Stripe::Charge.create(options)
  end
end

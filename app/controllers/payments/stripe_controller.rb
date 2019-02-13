class Payments::StripeController < ApplicationController

  before_filter :check_form_validity, only: :create
  before_action :authenticate_user!
  before_action :set_task, only: [:create, :new]

  def new
    @available_cards = Payments::StripeSources.new.call(user: current_user)
  end

  def create
    cent_amount = CurrencyConversion.usd_to_cents(params[:amount])
    payments_stripe = Payments::Stripe.new(stripe_token: params[:stripeToken], user: current_user, task: @task, card_id: params["card_id"],persist_card: params["save_card"])
    transaction = payments_stripe.direct_charge!(cent_amount)
    if transaction.present?
      FundTransactionService.perform_post_operation(@task, current_user, cent_amount)
      Project.sent_mail_after_charge(task: @task, user: current_user, cent_amount: cent_amount)
      # Funding a task adds user to teammates
      team_member = TeamMembership.find_by(team_member: current_user, team: @task.project.team)
      TeamService.add_team_member(@task.project.team, current_user, 'teammate') unless team_member
      PaymentMailer.tax_deduction_information(payer: current_user, task: @task, transaction_id: transaction.id).deliver_later

      render json: { id: transaction.id, success: t('controllers.payments.thanks_you') }, status: 200
    else
      render json: { error: 'Something went wrong' }, status: 403
    end
  rescue Payments::BTC::Errors::GeneralError => error
    ErrorHandlerService.call(error)
    render json: { error: UserErrorPresenter.new(error).message }, status: 500
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def mock_mode?
     ENV["use_mocked"] && params[:stripeToken].eql?("STRIPE_TOKEN_FOR_QA")
  end

  def check_form_validity
    unless (params.key?(:stripeToken) || params.key?(:card_id)) && params.key?(:amount)
      render json: { error: t('controllers.payments.invalid_parameters') }, status: 500
    end
  end

  # def amount_in_bitcoin
  #   Payments::BTC::Converter.convert_usd_to_btc(params[:amount])
  # end
end

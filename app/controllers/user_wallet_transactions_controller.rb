class UserWalletTransactionsController < ApplicationController
  before_action :authenticate_user!

  COINBASE_API_TURN_CODE_TO_TOKEN_URL = "https://api.coinbase.com/oauth/token"
  COINBASE_API_BASE_URL = "https://api.coinbase.com/v2/user"

  # def send_to_any_address
    # transfer = Payments::BTC::FundBtcAddress.new(
    #   amount: amount_in_satoshi,
    #   address_to: params['wallet_transaction_user_wallet'],
    #   user: current_user
    # )
    # transfer.submit!

  #   @message = t('.success', amount: params[:amount], transfer_address: transfer.address_to)
  #   redirect_to my_wallet_user_url(current_user), notice: @message
  # rescue Payments::BTC::Errors::GeneralError => error
  #   ErrorHandlerService.call(error)
  #   @message = UserErrorPresenter.new(error).message
  #   redirect_to my_wallet_user_url(current_user), alert: @message
  # end

  def send_to_task_address
    task = Task.find(params[:task_id])
    #
    # @transfer = Payments::BTC::FundTask.new(
    #   amount: amount_in_satoshi,
    #   task: task,
    #   user: current_user
    # )
    # @transfer.submit!
    task.interested_users.each do |user|
      PaymentMailer.fund_task(
        payer: current_user,
        task: task,
        receiver: user,
        amount: { bitcoin: params[:amount], usd: amount_in_usd.round(2) }
      ).deliver_later

      # reload to make sure you get the latest fund
      task.reload
      PaymentMailer.fully_funded_task(
        task: task,
        receiver: user
      ).deliver_later if task.fully_funded?
    end

    # Funding a task adds user to teammates
    TeamService.add_team_member(task.project.team, current_user, "teammate")

    render json: { success: t('.success', amount: params[:amount]) }, status: 200
  rescue Payments::BTC::Errors::GeneralError => error
    ErrorHandlerService.call(error)
    render json: { error: UserErrorPresenter.new(error).message }, status: 500
  end

  # Used as redirect from Coinbase Connect
  # def send_to_personal_coinbase
  #   data = params.permit(:code)
  #   coinbase_email = coinbase_email_from_code(data[:code])

    # amount = current_user.wallet.balance if current_user.wallet
    # if coinbase_email && amount
      # transfer = Payments::BTC::FundBtcAddress.new(
      #   amount: amount,
      #   address_to: coinbase_email,
      #   user: current_user,
      #   send_to_email: true
      # )
      # transfer.submit!

      # @message = t('.success', amount: amount, transfer_address: coinbase_email)
      # redirect_to my_wallet_user_url(current_user), notice: @message
    # else
    #   @message = t('.error_wallet')
    #   redirect_to my_wallet_user_url(current_user), alert: @message
    # end
  # rescue Payments::BTC::Errors::GeneralError => error
  #   ErrorHandlerService.call(error)
  #   @message = UserErrorPresenter.new(error).message
  #   redirect_to my_wallet_user_url(current_user), alert: @message
  # end

  # private

  # param :code is sent by Coinbase and used to fetch users :access_token - necessary to get the email
  # https://developers.coinbase.com/docs/wallet/coinbase-connect/integrating
  # def coinbase_email_from_code(code)
  #   # get access token using code:
  #   token_response = RestClient.post COINBASE_API_TURN_CODE_TO_TOKEN_URL,
  #                   {
  #                     "grant_type" => "authorization_code",
  #                     "code" => code,
  #                     "client_id" => ENV['coinbase_client_id'],
  #                     "client_secret" => ENV['coinbase_client_secret'],
  #                     "redirect_uri" => request.base_url + "/user_wallet_transactions/send_to_personal_coinbase"
  #                   }.to_json,
  #                   {content_type: :json, accept: :json}
  #
  #   token = JSON.parse(token_response.body)["access_token"]
  #   token_type = JSON.parse(token_response.body)["token_type"].capitalize
  #
  #   # get users email using access token:
  #   email_response = RestClient.get COINBASE_API_BASE_URL,
  #                                   {authorization: "#{token_type} #{token}"}
  #   JSON.parse(email_response.body)["data"]["email"]
  # end
end

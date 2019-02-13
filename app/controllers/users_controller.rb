class UsersController < ApplicationController
  load_and_authorize_resource :except => [:index]
  layout "dashboard", only: [:my_projects]
  before_action :add_bank_card, only: [:credit_card, :bank]
  def index
    authorize! :index, current_user
    @users = User.all
  end

  def show
    @header_class = "dashboard"
    @user = User.not_hidden.find(params[:id])
    @task_reviews = @user.user_history_task_reviews
    @average_rating = @user.user_average_rating
    @profile_comments = @user.profile_comments.limit(3)
  end

  def my_projects
    @header_class = "dashboard"
    @user = current_user
  end

  def update
    @user = User.find(params[:id])

    @user.attributes = update_params
    if @user.invalid?

      respond_to do |format|
        #flash[:error] = message
        format.js {render json: @user.errors.full_messages, status: :unprocessable_entity}
        format.html {redirect_to @user}
      end
    else
      @user.save
      current_user.create_activity(@user, 'updated')
      respond_to do |format|
        format.js {render json: true, status: 201}
        format.html {render :show}
      end
    end
  end

  def destroy
    user = User.find(params[:id])
    user.destroy
    current_user.create_activity(@user, 'deleted')
    redirect_to users_path, notice: t('.success')
  end

  def my_wallet
    @header_class = "dashboard"
    @transactions = current_user.all_transaction_histories
    @user_balance = current_user.balance.amount
    @hold_balance = current_user.hold_amount
  end

  def payout
    payout = current_user.create_payout_detail(payout_params)
    acct_details = Payments::Stripe.create_custom_acc(payout_params.merge(user_id: current_user.id, token: params[:token]))
    if(acct_details[0].eql?(true) && payout.save!)
      current_user.build_custom_account(acc_id: acct_details[1].id,
      status: CustomAccount.statuses["unverified"])
      Rails.logger.debug "Custom account create with payout #{acct_details[1].id}"
    else
      flash[:error] = acct_details[1]
      flash[:payout_details] = payout_params
      redirect_to payout_details_user_path
    end
  end

  def payout_details
    @form_params = flash[:payout_details] || {}
  end

  def credit_card
  end

  def bank
  end

  def verify
    return if request.request_method.eql?("GET")
    begin
      res = Payments::Stripe.update_personal_id({custom_acc_id: current_user.custom_account.acc_id, token: params[:token]} )
      if res[0].eql?(true)
        previous_status = current_user.custom_account.status
        current_user.custom_account.update_attributes(status: CustomAccount.custom_acc_status(res[1].legal_entity.verification.status))
        NotificationMailer.stripe_account_update(current_user.id, previous_status).deliver_later
        flash[:notice] = "Details Updated Successfully"
        redirect_to payout_method_user_path
      else
        flash[:error] = res[1]
        redirect_to verify_user_path
      end
    rescue StandardError => e
      flash[:error] = e.message
      redirect_to verify_user_path
    end

  end

  def add_bank_card
    return if request.request_method.eql?("GET")
    card_action = params["action"].eql?("credit_card") ? true : false
    if card_action
      params_send = params["stripeToken"]
      call_action = "create_external_card"
      red_url     = credit_card_user_path
      flash_msg   = "Card added successfully"
    else
      params_send = params["bank"]
      call_action = "create_external_bank"
      red_url     = bank_user_path
      flash_msg   = "Bank added successfully"
    end
    res = current_user.send(call_action, params_send)
    if res[0].eql?(false)
      flash[:error] = res[1]
      redirect_to red_url
    else
      flash[:notice] = flash_msg
      redirect_to payout_method_user_path(current_user)
    end
  end


  def remove_external
    res = current_user.delete_external_accounts(params)
    if res[0]
      flash[:notice] = "External Account Deleted Successfully"
    else
      flash[:error] = res[1]
    end
    redirect_to payout_method_user_path(current_user)
  end

  def state
    if params["state"].present?
      @data = CS.cities(params["state"], params["country"])
    else
      @data = CS.states(params["country"])
    end
    respond_to do |format|
      format.json { render json: @data }
    end
  end

  def payout_external
    begin
      response = current_user.payout_transaction(params["source_type"])
      unless response[0]
        flash[:error] = t("commons.withdrawal_error")
        NotificationMailer.send_error_to_admin(current_user, response[1]).deliver_later
        redirect_to withdraw_method_user_path
      end
    rescue StandardError => e
      flash[:error] = e.message
      redirect_to withdraw_method_user_path
    end
  end

  private

  def update_params
    allowed = [:first_name, :last_name, :picture, :password, :bio, :city,
               :state, :phone_number, :bio, :facebook_url, :twitter_url,
               :skype_id, :facebook_id, :linkedin_id, :twitter_id,
               :picture_crop_x, :picture_crop_y, :picture_crop_w,
               :picture_crop_h, :linkedin_url, :picture_cache,
               :background_picture, :preferred_language]
    allowed << :email if current_user.email.blank?
    params.require(:user).permit(*allowed)
  end

  def secure_params
    params.require(:user).permit(:role, :picture, :name, :email, :password, :bio,
                                 :city, :phone_number, :bio, :facebook_url, :twitter_url,
                                 :linkedin_url, :picture_cache)
  end

  def payout_params
    params.permit(:state, :country, :city, :address, :postal_code,
                                   :first_name, :last_name, :dob, :ssn, :last_4_ssn, :legal_document)
  end

end

class ApplicationController < ActionController::Base

  rescue_from CanCan::AccessDenied do |exception|
    msg = Rails.env.production? ? t('controllers.cancan_access_denied') : exception.message
    respond_to do |format|
      format.html { redirect_to main_app.root_url, notice: msg }
      format.json { render json: { message: msg }, status: :unauthorized }
      format.js { render json: { message: msg }, status: :unauthorized }
      format.any { redirect_to main_app.root_url, notice: msg }
    end
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    msg = Rails.env.production? ? t('controllers.active_record_not_found') : exception.message
    respond_to do |format|
      format.html { redirect_to main_app.root_url, notice: msg }
      format.json { render json: { message: msg }, status: :not_found }
      format.js { render json: { message: msg }, status: :not_found }
      format.any { redirect_to main_app.root_url, notice: msg }
    end
  end

  rescue_from ActionController::ParameterMissing do |exception|
    msg = Rails.env.production? ? t('users.update.fail') : exception.message
    respond_to do |format|
      format.any { redirect_to main_app.root_url, status: 304, notice: msg }
    end
  end

  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    msg = Rails.env.production? ? t('controllers.unauthorized_message') : exception.message
    respond_to do |format|
      format.html { redirect_to main_app.root_url, notice: msg }
      format.json { render json: { message: msg }, status: :not_found }
      format.js { render json: { message: msg }, status: :not_found }
      format.any { redirect_to main_app.root_url, notice: msg }
    end
  end

  protect_from_forgery with: :exception
  around_filter :set_current_user
  after_filter :user_activity
  after_action :flash_to_headers
  before_action :basic_http_auth, :set_locale, :check_existing_email_for_user
  helper_method :current_user?


  def set_locale
    # users locale (changed using the language selector) gets first preference
    # locale from params (when non logged users select the language)
    # location detected is the guess based on IP
    I18n.locale = locale_prefered || locale_from_params || location_detected_locale || I18n.default_locale
    redirect_to_correct_locale
  end

  def redirect_to_correct_locale
    # only when the request is get and locale is missing redirect with locale
    if (request.get? && !request.xhr?) &&
      ((params[:locale].blank? && I18n.locale != I18n.default_locale) ||
        params[:locale] && params[:locale] != I18n.locale.to_s)

      locale = I18n.available_locales.include?(I18n.locale) ? I18n.locale : I18n.default_locale
      new_params = request.query_parameters.merge({ locale: locale })
      redirect_to url_for(new_params) and return
    end
  end

  # when user changes the locale from the the language selector it changes the preferred language of the user
  def locale_prefered
    current_user.preferred_language if current_user && (I18n.available_locales.map(&:to_s).include? current_user.preferred_language)
  end

  def locale_from_params
    params[:locale] if (I18n.available_locales.map(&:to_s).include? params[:locale])
  end
  
  def location_detected_locale
    location = request.location
    location_code = location&.country_code&.downcase&.to_sym
    I18n.available_locales.include?(location_code) ? location_code : nil
  end

  def default_url_options(options = {})
    if (I18n.default_locale != I18n.locale) && (I18n.available_locales.include? I18n.locale)
      {locale: I18n.locale}.merge options
    else
      {locale: nil}.merge options
    end
  end

  def set_current_user
    User.current_user = current_user
    yield
  ensure
    User.current_user = nil
  end

  def admin_only_mode
    unless current_user.try(:admin?)
      unless params[:controller] == 'visitors' || params[:controller] == 'registrations' || params[:controller] == 'sessions'
        redirect_to :controller => 'visitors', :action => 'restricted', :alert => t('controllers.admin_only_mode.admin_mode_activated')
      end

      if params[:controller] == 'visitors' && params[:action] == 'index'
        redirect_to :controller => 'visitors', :action => 'restricted', :alert => t('controllers.admin_only_mode.admin_mode_activated')
      end
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:name, :email, :password,
      :password_confirmation, :current_password, :picture, :company, :country, :description, :first_link, :second_link, :third_link, :fourth_link, :city, :picture_cache, :phone_number) }
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:name, :email, :password,
      :password_confirmation, :current_password, :picture, :company, :country, :description, :first_link, :second_link, :third_link, :fourth_link, :city, :picture_cache, :phone_number) }
    devise_parameter_sanitizer.permit(:sign_in) { |u| u.permit(:name, :email, :password,
      :password_confirmation, :current_password, :picture, :company, :country, :description, :first_link, :second_link, :third_link, :fourth_link, :city, :picture_cache, :phone_number) }
  end

  def default_api_value
    t("#{service_name}.#{service_action}", :default => {})
  end

  def service_name
    params[:controller].gsub(/^.*\//, "")
  end

  def service_action
    params[:action]
  end

  def wallet_handler
    Payments::BTC::WalletHandler.new
  end

  def basic_http_auth
    if ENV['HTTP_BASIC_AUTHENTICATION_PASSWORD'].present?
      authenticate_or_request_with_http_basic do |user, password|
        user == 'weserve' && password == ENV["HTTP_BASIC_AUTHENTICATION_PASSWORD"]
      end
    end
  end

  helper_method :service_action, :service_name

  def flash_to_headers
    return unless request.xhr?

    messages ||= {}

    flash.each do |type, msg|
      css_type = 'alert'
      css_type = 'success' if type.to_s == 'notice'

      messages[css_type] = msg
    end

    response.headers['X-Messages'] = messages.to_json

    flash.discard # don't want the flash to appear when you reload page
  end

  # Using resouce out of devise controllers
  # https://github.com/plataformatec/devise/wiki/How-To:-Display-a-custom-sign_in-form-anywhere-in-your-app
  def resource
    @resource ||= User.new
  end
  helper_method :resource

  def resource_name
    :user
  end
  helper_method :resource_name

  def devise_mapping
    @devise_mapping ||= Devise.mappings[resource_name]
  end
  helper_method :devise_mapping

  def current_user?(user)
    current_user && current_user.id.eql?(user.id)
  end


  private

  def check_existing_email_for_user
    if current_user.present? && current_user.email.blank?
      unless current_user.unconfirmed_email.blank?
        flash.now[:error] = t('landing.errors.unconfirmed_email')
      end
    end
  end

  def user_activity
    current_user.try :update_attribute, :last_seen_at, Time.zone.now
  end

  protected
  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || stored_location_for(resource) || root_path
  end
end

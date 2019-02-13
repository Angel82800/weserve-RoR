class Api::V1::BaseController < ActionController::Base
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    msg = Rails.env.production? ? t('controllers.cancan_access_denied') : exception.message
    respond_to do |format|
      format.any { render json: { message: msg }, status: :unauthorized }
    end
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    msg = Rails.env.production? ? t('controllers.active_record_not_found') : exception.message
    respond_to do |format|
      format.any { render json: { message: msg }, status: :not_found }
    end
  end


end

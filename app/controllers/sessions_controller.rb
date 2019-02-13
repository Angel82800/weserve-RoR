class SessionsController < Devise::SessionsController
  respond_to :json
  include Mediawiki

  after_action :after_login, only: :create
  after_action :after_logout, only: :destroy

  def after_login
    set_cookies current_user
  end

  def after_logout
    domain = ENV['mediawiki_domain']
    cookie_prefix = ENV['mediawiki_cookie_prefix']
    cookies.delete("#{cookie_prefix}_ws_user_id".to_sym, domain: domain)
    cookies.delete("#{cookie_prefix}_ws_user_name".to_sym, domain: domain)
    cookies.delete("#{cookie_prefix}_ws_user_token".to_sym, domain: domain)
  end

end

module Mediawiki

  def set_cookies(resource)
    secret = ENV['mediawiki_secret']
    domain = ENV['mediawiki_domain']
    cookie_prefix = ENV['mediawiki_cookie_prefix']

    cookies.permanent["#{cookie_prefix}_ws_user_id"] = {
        value: resource.id,
        domain: domain
    }

    cookies.permanent["#{cookie_prefix}_ws_user_name"] = {
        value: resource.username,
        domain: domain
    }

    cookies.permanent["#{cookie_prefix}_ws_user_token"] = {
        value: Digest::MD5.hexdigest("#{secret}#{resource.id}#{resource.username}"),
        domain: domain
    }
  end

end
require 'rest-client'
require 'json'
require 'resolv-replace'

Rails.application.configure do
  # Extract credentials
  lgusername = ENV['mediawiki_username']
  lgpassword = ENV['mediawiki_password']
  api_base_url = ENV['mediawiki_api_base_url']
  # Fetch login token
  response = RestClient.get("#{api_base_url}api.php?action=query&meta=tokens&type=login&format=json")
  Rails.logger.debug "Mediawiki response #{response}"
  # Save cookies
  cookies = response.cookies
  # Extract token
  token = JSON.parse(response)['query']['tokens']['logintoken']

  # Do a login
  result = RestClient.post("#{api_base_url}api.php?action=login",
    {
      lgname: lgusername,
      lgpassword:lgpassword,
      lgtoken: token,
      format: 'json'
    },
    {
      :cookies => cookies
    }
  )
  # Save session cookies
  config.mediawiki_session = result.cookies
  Rails.logger.debug "Initialized Mediawiki session #{result.cookies}"
  Rails.logger.debug "Mediawiki response #{result}"
end

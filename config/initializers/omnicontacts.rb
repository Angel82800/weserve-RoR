require "omnicontacts"

Rails.application.middleware.use OmniContacts::Builder do
  importer :gmail, ENV["gapp_id"], ENV["gapp_secret_key"], {:redirect_path => "/oauth2callback"}
  #Development
  # importer :yahoo, "dj0yJmk9ZmNRNzN2Zkx0T0UzJmQ9WVdrOVJEZEViVXRMTXpJbWNHbzlNQS0tJnM9Y29uc3VtZXJzZWNyZXQmeD1mOQ--", "6b513da14b41b15761e1a574b864cf5b728418af", {:callback_path => '/callback'}
  #Production
  importer :yahoo, ENV["yahoo_client_id"], ENV["yahoo_client_secret"], {:callback_path => '/callback'}
end

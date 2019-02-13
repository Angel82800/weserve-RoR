module ApiHelper
  include Rack::Test::Methods

  def app
    Rails.application
  end

  def last_response_hash
    JSON.parse(last_response.body).with_indifferent_access
  end
end
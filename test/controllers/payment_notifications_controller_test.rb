require 'test_helper'

class PaymentNotificationsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  test "should get create" do
    get :create
    assert_response :success
  end

end

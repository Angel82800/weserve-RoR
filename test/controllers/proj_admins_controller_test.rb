require 'test_helper'

class ProjAdminsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get create" do
    get :create
    assert_response :success
  end

  test "should get destroy" do
    get :destroy
    assert_response :success
  end

end

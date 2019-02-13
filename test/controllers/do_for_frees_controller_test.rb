require 'test_helper'

class DoForFreesControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get create" do
    get :create
    assert_response :success
  end

  test "should get update" do
    get :update
    assert_response :success
  end

  test "should get destroy" do
    get :destroy
    assert_response :success
  end

  test "should get accept" do
    get :accept
    assert_response :success
  end

  test "should get reject" do
    get :reject
    assert_response :success
  end

end

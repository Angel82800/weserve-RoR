require 'test_helper'

class WorkRecordsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  setup do
    @work_record = work_records(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:work_records)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create work_record" do
    assert_difference('WorkRecord.count') do
      post :create, work_record: {  }
    end

    assert_redirected_to work_record_path(assigns(:work_record))
  end

  test "should show work_record" do
    get :show, id: @work_record
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @work_record
    assert_response :success
  end

  test "should update work_record" do
    patch :update, id: @work_record, work_record: {  }
    assert_redirected_to work_record_path(assigns(:work_record))
  end

  test "should destroy work_record" do
    assert_difference('WorkRecord.count', -1) do
      delete :destroy, id: @work_record
    end

    assert_redirected_to work_records_path
  end
end

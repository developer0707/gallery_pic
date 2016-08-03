require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "should get search" do
    get :search
    assert_response :success
  end

  test "should get follow" do
    get :follow
    assert_response :success
  end

  test "should get report" do
    get :report
    assert_response :success
  end

  test "should get update" do
    get :update
    assert_response :success
  end

end

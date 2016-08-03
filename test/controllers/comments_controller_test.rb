require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  test "should get destroy" do
    get :destroy
    assert_response :success
  end

  test "should get like" do
    get :like
    assert_response :success
  end

  test "should get report" do
    get :report
    assert_response :success
  end

  test "should get create" do
    get :create
    assert_response :success
  end

  test "should get index" do
    get :index
    assert_response :success
  end

end

require 'test_helper'

class CountersControllerTest < ActionController::TestCase
  test "should get users" do
    get :users
    assert_response :success
  end

  test "should get posts" do
    get :posts
    assert_response :success
  end

  test "should get comments" do
    get :comments
    assert_response :success
  end

end

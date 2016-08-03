require 'test_helper'

class ImportsControllerTest < ActionController::TestCase
  test "should get categories" do
    get :categories
    assert_response :success
  end

  test "should get countries" do
    get :countries
    assert_response :success
  end

  test "should get states" do
    get :states
    assert_response :success
  end

  test "should get cities" do
    get :cities
    assert_response :success
  end

  test "should get places" do
    get :places
    assert_response :success
  end

  test "should get installations" do
    get :installations
    assert_response :success
  end

  test "should get sessions" do
    get :sessions
    assert_response :success
  end

  test "should get users" do
    get :users
    assert_response :success
  end

  test "should get actions" do
    get :actions
    assert_response :success
  end

  test "should get comments" do
    get :comments
    assert_response :success
  end

  test "should get places" do
    get :places
    assert_response :success
  end

  test "should get posts" do
    get :posts
    assert_response :success
  end

end

require 'test_helper'

class Api::PhotosControllerTest < ActionController::TestCase
  test "should get show" do
    get :show
    assert_response :success
  end

end

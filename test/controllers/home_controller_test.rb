require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "should get about page" do
    get :about
    assert_response :success
  end

  test "should get impressum" do
    get :impressum
    assert_response :success
  end
end
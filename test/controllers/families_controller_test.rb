require 'test_helper'

class FamiliesControllerTest  < ActionController::TestCase
  setup do
    @family = families(:lentibulariaceae)
    user_log_in
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should show family" do
    get :show, family: @family
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get edit" do
    get :edit, family: @family
    assert_response :success
  end

  test "should create family" do
    assert_difference('Family.count') do
      post :create, family: { name: 'Byblidaceae' }
    end

    assert_redirected_to family_path(assigns(:family))
  end

  test "should update family" do
    patch :update, id: @family, family: { name: 'Calceolariaceae' }
    assert_redirected_to family_path(assigns(:family))
  end

  test "should destroy family" do
    assert_difference('Family.count', -1) do
      delete :destroy, id: @family
    end

    assert_redirected_to families_path
  end
end
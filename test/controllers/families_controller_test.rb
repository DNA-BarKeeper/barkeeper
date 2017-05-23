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
    get :show, params: { id: @family }
    assert_response :success
  end

  test "should get edit" do
    get :edit, params: { id: @family }
    assert_response :success
  end

  test "should update family" do
    patch :update, params: { id: @family, family: { name: 'Calceolariaceae' } }
    assert_redirected_to families_path
  end

  test "should destroy family" do
    assert_difference('Family.count', -1) do
      delete :destroy, params: { id: @family }
    end

    assert_redirected_to families_path
  end
end
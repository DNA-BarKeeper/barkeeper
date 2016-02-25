require 'test_helper'

class IndividualsControllerTest < ActionController::TestCase

  setup do
    @project = projects(:gbol5)
    @individual = individuals(:second_specimen)
  end

  test "should get index" do
    #TODO should be possible to factor out user_log_in
    user_log_in
    get :index
    assert_response :success
  end

  test "should get new" do
    user_log_in
    get :new
    assert_response :success
  end

  test "should create individual" do
    user_log_in
    assert_difference('Individual.count') do
      post :create, individual: { specimen_id: 'sadlgkjhlkj2' }
    end

    assert_redirected_to individual_path(assigns(:individual))
  end

  test "should show individual" do
    user_log_in
    get :show, id: @individual
    assert_response :success
  end

  test "should get edit" do
    user_log_in
    get :edit, id: @individual
    assert_response :success
  end

  test "should update individual" do
    user_log_in
    patch :update, id: @individual, individual: { specimen_id: 'sadfdghji435' }
    assert_redirected_to individuals_path
  end

  test "should destroy individual" do
    user_log_in
    assert_difference('Individual.count', -1) do
      delete :destroy, id: @individual
    end

    assert_redirected_to individuals_path
  end
end

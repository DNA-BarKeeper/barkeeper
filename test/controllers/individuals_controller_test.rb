require 'test_helper'

class IndividualsControllerTest < ActionController::TestCase

  setup do
    @project = projects(:gbol5)
    @individual = individuals(:specimen1)

    user_log_in
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create individual" do
    assert_difference('Individual.count') do
      post :create, individual: { specimen_id: 'sadlgkjhlkj2' }
    end

    assert_redirected_to individuals_path
  end

  test "should show individual" do
    get :show, id: @individual
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @individual
    assert_response :success
  end

  test "should update individual" do
    patch :update, id: @individual, individual: { specimen_id: 'sadfdghji435' }
    assert_redirected_to individuals_path
  end

  test "should destroy individual" do
    assert_difference('Individual.count', -1) do
      delete :destroy, id: @individual
    end

    assert_redirected_to individuals_path
  end
end

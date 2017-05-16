require 'test_helper'

class PrimersControllerTest < ActionController::TestCase
  setup do
    @primer = primers(:its4)
    user_log_in
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should show primer" do
    get :show, id: @primer
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @primer
    assert_response :success
  end

  test "should create primer" do
    assert_difference('Primer.count') do
      post :create, primer: { name: 'ITS5', alt_name: 'nr5', reverse: false }
    end

    assert_redirected_to primers_path
  end

  test "should update primer" do
    patch :update, id: @primer, primer: { reverse: false }
    assert_redirected_to primers_path
  end

  test "should destroy primer" do
    assert_difference('Primer.count', -1) do
      delete :destroy, id: @primer
    end

    assert_redirected_to primers_url
  end
end
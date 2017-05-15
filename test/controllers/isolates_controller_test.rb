require 'test_helper'

class IsolatesControllerTest < ActionController::TestCase

  setup do
    @isolate = isolates(:gbol2119)

    user_log_in
  end

  test "should get duplicates" do
    get :duplicates
    assert_response :success
  end

  test "should get isolates without specimen" do
    get :no_specimen
    assert_response :success
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create isolate" do
    assert_difference('Isolate.count') do
      post :create, isolate: { lab_nr: 'GBOL7012', tissue: 'seed', isCopy: false }
    end

    assert_redirected_to isolates_path
  end

  test "should show isolate" do
    get :show, id: @isolate
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @isolate
    assert_response :success
  end

  test "should update isolate" do
    patch :update, id: @isolate, isolate: { lab_nr: 'GBoL3456', tissue: 'pollen', individual: 'specimen1' }
    assert_redirected_to isolates_path
  end

  test "should destroy isolate" do
    assert_difference('Isolate.count', -1) do
      delete :destroy, id: @isolate
    end

    assert_redirected_to isolates_path
  end
end
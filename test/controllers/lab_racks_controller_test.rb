require 'test_helper'

class LabRacksControllerTest < ActionController::TestCase

  setup do
    @lab_rack = lab_racks(:GBoL5_1)

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

  test "should create lab rack" do
    assert_difference('LabRack.count') do
      post :create, lab_rack: { freezer: 'freezer1', shelf: 'shelf1', rackcode: 'GBoL5_2' }
    end

    assert_redirected_to lab_racks_path
  end

  test "should show lab rack" do
    get :show, id: @lab_rack
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @lab_rack
    assert_response :success
  end

  test "should update lab rack" do
    patch :update, id: @lab_rack, lab_rack: { rackcode: 'GBoL5_0' }
    assert_redirected_to lab_racks_path
  end

  test "should destroy lab rack" do
    assert_difference('LabRack.count', -1) do
      delete :destroy, id: @lab_rack
    end

    assert_redirected_to lab_racks_url
  end
end
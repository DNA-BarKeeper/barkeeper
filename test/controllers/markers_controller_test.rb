require 'test_helper'

class MarkersControllerTest < ActionController::TestCase
  setup do
    @marker = markers(:ITS)

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

  test "should create marker" do
    assert_difference('Marker.count') do
      post :create, params: { marker: { name: 'rbcL', is_gbol: false, expected_reads: 1 } }
    end

    assert_redirected_to markers_path
  end

  test "should show marker" do
    get :show, params: { id: @marker }
    assert_response :success
  end

  test "should get edit" do
    get :edit, params: { id: @marker }
    assert_response :success
  end

  test "should update marker" do
    patch :update, params: { id: @marker, marker: { alt_name: 'NR5_NR4' } }
    assert_redirected_to markers_path
  end

  test "should destroy marker" do
    assert_difference('Marker.count', -1) do
      delete :destroy, params: { id: @marker }
    end

    assert_redirected_to markers_url
  end
end
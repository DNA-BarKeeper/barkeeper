require 'test_helper'

class MicronicPlatesControllerTest < ActionController::TestCase
  setup do
    @micronic_plate = micronic_plates(:G5c1000131)

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

  test "should create micronic plate" do
    assert_difference('MicronicPlate.count') do
      post :create, micronic_plate: { name: 'G5c1000124', lab_rack: 'GBoL5_1' }
    end

    assert_redirected_to micronic_plates_path
  end

  test "should show micronic plate" do
    get :show, id: @micronic_plate
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @micronic_plate
    assert_response :success
  end

  test "should update micronic plate" do
    patch :update, id: @micronic_plate, micronic_plate: { name: 'G5o1000144' }
    assert_redirected_to micronic_plates_path
  end

  test "should destroy micronic plate" do
    assert_difference('MicronicPlate.count', -1) do
      delete :destroy, id: @micronic_plate
    end

    assert_redirected_to micronic_plates_url
  end
end
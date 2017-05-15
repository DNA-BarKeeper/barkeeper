require 'test_helper'

class PlantPlatesControllerTest < ActionController::TestCase
  setup do
    @plant_plate = plant_plates(:plant_plate1)
    user_log_in
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should show plant plate" do
    get :show, id: @plant_plate
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @plant_plate
    assert_response :success
  end

  test "should create plant plate" do
    assert_difference('PlantPlate.count') do
      post :create, plant_plate: { name: '67' }
    end

    assert_redirected_to plant_plates_path
  end

  test "should update plant plate" do
    patch :update, id: @plant_plate, plant_plate: { name: '98' }
    assert_redirected_to plant_plates_path
  end

  test "should destroy plant plate" do
    assert_difference('PlantPlate.count', -1) do
      delete :destroy, id: @plant_plate
    end

    assert_redirected_to plant_plates_url
  end
end
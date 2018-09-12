# frozen_string_literal: true

require 'test_helper'

class IndividualsControllerTest < ActionController::TestCase
  setup do
    @individual = individuals(:specimen1)

    user_log_in
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should get specimens without species' do
    get :specimens_without_species
    assert_response :success
  end

  test 'should get individuals with problematic location data' do
    get :problematic_location_data
    assert_response :success
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create individual' do
    assert_difference('Individual.count') do
      post :create, params: { individual: { specimen_id: 'sadlgkjhlkj2' } }
    end

    assert_redirected_to individuals_path
  end

  test 'should show individual' do
    get :show, params: { id: @individual }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @individual }
    assert_response :success
  end

  test 'should update individual' do
    patch :update, params: { id: @individual, individual: { specimen_id: 'sadfdghji435' } }
    assert_redirected_to individuals_path
  end

  test 'should destroy individual' do
    assert_difference('Individual.count', -1) do
      delete :destroy, params: { id: @individual }
    end

    assert_redirected_to individuals_path
  end
end

# frozen_string_literal: true

require 'test_helper'

class SpeciesControllerTest < ActionController::TestCase
  setup do
    @species = species(:urtica_dioica)
    user_log_in
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should show species' do
    get :show, params: { id: @species }
    assert_response :success
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @species }
    assert_response :success
  end

  test 'should create species' do
    assert_difference('Species.count') do
      post :create, params: { species: { name: 'Pilea cadierei', author: 'unknown', family: 'urticaceae' } }
    end

    assert_redirected_to species_index_path
  end

  test 'should update species' do
    patch :update, params: { id: @species, species: { author: 'Linné' } }
    assert_redirected_to species_index_path
  end

  test 'should destroy species' do
    assert_difference('Species.count', -1) do
      delete :destroy, params: { id: @species }
    end

    assert_redirected_to species_index_url
  end
end

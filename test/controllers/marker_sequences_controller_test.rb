# frozen_string_literal: true

require 'test_helper'

class MarkerSequencesControllerTest < ActionController::TestCase
  setup do
    @marker_sequence = marker_sequences(:GBoL3635_ITS)

    user_log_in
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create marker sequence' do
    assert_difference('MarkerSequence.count') do
      post :create, params: { marker_sequence: { name: 'GBoL3635_ITS', marker: 'ITS' } }
    end

    assert_redirected_to marker_sequences_path
  end

  test 'should show marker sequence' do
    get :show, params: { id: @marker_sequence }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @marker_sequence }
    assert_response :success
  end

  test 'should update marker sequence' do
    patch :update, params: { id: @marker_sequence, marker_sequence: { name: 'GBoL1516_ITS' } }
    assert_redirected_to edit_marker_sequence_path
  end

  test 'should destroy marker sequence' do
    assert_difference('MarkerSequence.count', -1) do
      delete :destroy, params: { id: @marker_sequence }
    end

    assert_redirected_to marker_sequences_url
  end
end

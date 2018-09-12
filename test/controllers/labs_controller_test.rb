# frozen_string_literal: true

require 'test_helper'

class LabsControllerTest < ActionController::TestCase
  setup do
    @lab = labs(:bonn)

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

  test 'should create lab' do
    assert_difference('Lab.count') do
      post :create, params: { lab: { labcode: 'NEES' } }
    end

    assert_redirected_to labs_path
  end

  test 'should show lab' do
    get :show, params: { id: @lab }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @lab }
    assert_response :success
  end

  test 'should update lab' do
    patch :update, params: { id: @lab, lab: { labcode: 'BGBM' } }
    assert_redirected_to labs_path
  end

  test 'should destroy lab' do
    assert_difference('Lab.count', -1) do
      delete :destroy, params: { id: @lab }
    end

    assert_redirected_to labs_url
  end
end

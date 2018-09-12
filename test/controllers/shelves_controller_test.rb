# frozen_string_literal: true

require 'test_helper'

class ShelvesControllerTest < ActionController::TestCase
  setup do
    @shelf = shelves(:shelf1)
    user_log_in
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should show shelf' do
    get :show, params: { id: @shelf }
    assert_response :success
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @shelf }
    assert_response :success
  end

  test 'should create shelf' do
    assert_difference('Shelf.count') do
      post :create, params: { shelf: { name: 'shelf2' } }
    end

    assert_redirected_to shelf_path(assigns(:shelf))
  end

  test 'should update shelf' do
    patch :update, params: { id: @shelf, shelf: { name: 'shelf3' } }
    assert_redirected_to shelf_path(@shelf)
  end

  test 'should destroy shelf' do
    assert_difference('Shelf.count', -1) do
      delete :destroy, params: { id: @shelf }
    end

    assert_redirected_to shelves_url
  end
end

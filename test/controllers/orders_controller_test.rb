# frozen_string_literal: true

require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  setup do
    @order = orders(:lamiales)
    user_log_in
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should show order' do
    get :show, params: { id: @order }
    assert_response :success
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @order }
    assert_response :success
  end

  test 'should create order' do
    assert_difference('Order.count') do
      post :create, params: { order: { name: 'Apiales' } }
    end

    assert_redirected_to orders_path
  end

  test 'should update order' do
    patch :update, params: { id: @order, order: { name: 'Asterales' } }
    assert_redirected_to orders_path
  end

  test 'should destroy order' do
    assert_difference('Order.count', -1) do
      delete :destroy, params: { id: @order }
    end

    assert_redirected_to orders_path
  end
end

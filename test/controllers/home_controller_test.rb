# frozen_string_literal: true

require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test 'should get overview page' do
    get :overview
    assert_response :success
  end

  test 'should get about page' do
    get :about
    assert_response :success
  end

  test 'should get impressum' do
    get :impressum
    assert_response :success
  end

  test 'should get help page' do
    get :help
    assert_response :success
  end

  test 'should get contact page' do
    get :contact
    assert_response :success
  end
end

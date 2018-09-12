# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test 'should get users index if user is kai' do
    @user = users(:kai)
    sign_in @user
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test 'should not get users index if user is not kai, show flash message instead' do
    @user = users(:default)
    sign_in @user
    get :index
    assert_redirected_to root_path
    assert_equal 'Access not allowed.', flash[:alert]
  end

  test 'should not get users if user not logged in, show sign-in page instead' do
    get :index
    assert_redirected_to '/users/sign_in'
  end

  test 'should show user' do
    @shown_user = users(:default)

    get :show, params: { id: @shown_user }
    assert_response :redirect
  end

  test 'should not get user/edit if user not kai, show flash message instead' do
    @user = users(:default)
    sign_in @user
    get :edit, params: { id: @user }
    assert_redirected_to root_path
    assert_equal 'Access not allowed.', flash[:alert]
  end

  test 'should get user/edit if user is kai' do
    @user = users(:kai)
    sign_in @user
    get :edit, params: { id: users(:default) }
    assert_template :edit
    assert_select 'select'
  end

  test 'kai should be able to assign additional project to user' do
    @user = users(:kai)
    sign_in @user

    @edited_user = users(:default)

    # puts 'Current project count: ' + @edited_user.projects.count.to_s

    assert_difference -> { @edited_user.projects.count }, 1, 'no project was added' do
      patch :update, params: { id: @edited_user, user: { project_ids: projects(:gbol5, :t3) } }
    end
  end

  test 'other than kai should not be able to assign additional projects to user' do
    @user = users(:default)
    sign_in @user

    assert_no_difference -> { @user.projects.count } do
      patch :update, params: { id: @user, user: { project_ids: projects(:gbol5, :t3) } }
    end
  end

  test 'as kai, should get new' do
    @user = users(:kai)
    sign_in @user
    get :new
    assert_response :success
  end

  test 'kai should be able to create new users' do
    @user = users(:kai)
    sign_in @user

    assert_difference('User.count') do
      post :create, params: { user: { name: 'test_user', email: 'test@example.com', password: 'password', password_confirmation: 'password' } }
    end

    assert_redirected_to user_path(assigns(:user))
  end
end

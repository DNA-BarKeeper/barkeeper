require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  test "should get users index if user is Kai" do
    @user = users(:kai)
    sign_in @user
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should not get users index if user is not kai, show flash message instead" do
    @user = users(:default)
    sign_in @user
    get :index
    assert_redirected_to root_path
    assert_equal 'Access not allowed.', flash[:alert]
  end

  test "should not get users if user not logged in, show sign-in page instead" do
    get :index
    assert_redirected_to '/users/sign_in'
  end

  test "should not get user/edit if user not kai, show flash message instead" do
    @user = users(:default)
    sign_in @user
    get :edit, id: @user
    assert_redirected_to root_path
    assert_equal 'Access not allowed.', flash[:alert]
  end

  test "should get user/edit if user is kai" do
    @user = users(:kai)
    sign_in @user
    get :edit, id: users(:default)
    assert_template :edit
    assert_select 'select'
  end

  test "kai should be able to assign additional project to user" do
    @user = users(:kai)
    sign_in @user

    @edited_user = users(:default)

    puts @edited_user.projects.count

    assert_difference ->{@edited_user.projects.count}, 1, 'no project was added.' do
      patch :update, id: @edited_user, user: {project_ids: projects(:gbol5, :t3)}
    end
   
  end

  test "other than kai should not be able to assign additional projects to user" do
    @user = users(:default)
    sign_in @user

    assert_no_difference ->{@user.projects.count} do
      patch :update, id: @user, user: {project_ids: projects(:gbol5, :t3)}
    end

  end
end
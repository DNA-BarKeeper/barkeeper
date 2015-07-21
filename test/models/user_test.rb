require 'test_helper'

class UserTest < ActiveSupport::TestCase

  setup do
    @user = users(:default)
  end

  test 'user with project should be valid' do
      assert @user.valid?
  end

  # test 'user without project should be invalid' do
  #   assert users(:invalid_user).invalid?, 'User should be invalid since no project'
  # end

end
ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/rails'
require 'minitest/rails/capybara'
require 'minitest/autorun' # needed?
require 'minitest/reporters'

class ActiveSupport::TestCase
  #Note: declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  ActiveRecord::Migration.check_pending!
  fixtures :all

end

module FixtureFileHelpers
  def encrypted_password(password = 'abcdef12!')
    User.new.send(:password_digest, password)
  end
end

ActiveRecord::FixtureSet.context_class.send :include, FixtureFileHelpers

def user_log_in
  @user = users(:default)
  sign_in @user
end

class ActionController::TestCase
  include Devise::TestHelpers
end
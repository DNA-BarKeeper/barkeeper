ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/rails'
require 'minitest/rails/capybara'
require 'minitest/autorun'

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
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
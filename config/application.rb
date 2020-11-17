# frozen_string_literal: true

require_relative 'boot'

require 'csv'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BarcodeWorkflowManager
  class Application < Rails::Application
    config.load_defaults 5.2

    # Keep old default of not requiring belongs to associations
    Rails.application.config.active_record.belongs_to_required_by_default = false

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # We want to set up a custom logger which logs to STDOUT.
    # Docker expects your application to log to STDOUT/STDERR and to be ran
    # in the foreground.
    config.log_level = :debug
    config.log_tags  = [:subdomain, :uuid]
    config.logger    = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))

    # Since we're using Redis for Sidekiq, we might as well use Redis to back
    # our cache store. This keeps our application stateless as well.
    config.cache_store = :redis_store, ENV['CACHE_URL'],
                         { namespace: 'barcode_workflow_manager::cache' }

    config.serve_static_assets = true

    config.assets.paths << "#{Rails}/app/assets/fonts"
    config.assets.paths << "#{Rails}/vendor/assets/fonts"

    # config.assets.enabled = true
    # config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif)

    config.autoload_paths << "#{Rails.root}/lib"
    config.eager_load_paths << "#{Rails.root}/lib"

    config.generators do |g|
      g.test_framework :rspec,
                       :fixtures => true,
                       :view_specs => false,
                       :helper_specs => false,
                       :routing_specs => false,
                       :controller_specs => true,
                       :request_specs => true
      g.fixture_replacement :factory_bot, :dir => 'spec/factories'
    end
  end
end

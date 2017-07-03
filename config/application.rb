require_relative 'boot'

require 'csv'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GBOLapp
  class Application < Rails::Application

    config.generators do |g|
      g.test_framework :minitest
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.assets.paths << "#{Rails}/app/assets/fonts"
    config.assets.paths << "#{Rails}/vendor/assets/fonts"

    # config.assets.enabled = true
    # config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif)

    config.paperclip_defaults = {
        :storage => :s3,
        :s3_credentials => {
            :bucket => ENV['S3_BUCKET_NAME'],
            :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
            :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
        },
        :s3_region => ENV['S3_REGION']
    }
  end
end

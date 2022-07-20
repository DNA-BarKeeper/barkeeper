# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.7.0'

gem 'rails', '5.2.8.1'

# Postgres
gem 'pg'
gem 'pg_search'

# Web server and background processing
gem 'puma'
gem 'redis-rails'
gem 'sidekiq'
gem 'sidekiq-client-cli'
gem 'sidekiq-limit_fetch'
gem 'sinatra', require: false # Needed to monitor sidekiq jobs

# Asset pipeline
gem 'coffee-rails' # Use CoffeeScript for .coffee assets and views
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'sass-rails' # Use SCSS for stylesheets
gem 'uglifier' # Use Uglifier as compressor for JavaScript assets

# Authentication & authorization
gem 'cancancan'
gem 'devise'

# External file storage
gem 'aws-sdk-s3', require: false
gem 'active_storage_validations'

# Javascript
gem 'jquery-datatables-rails', github: 'rweng/jquery-datatables-rails'
gem 'nested_form_fields'
gem 'jquery-fileupload-rails'
gem 'select2-rails' # Integrate Select2 Javascript library

gem 'ancestry' # Self-related models
gem 'bcrypt', platforms: :ruby
gem 'bio' # BioRuby
gem 'bootsnap'
gem 'bootstrap-sass'
gem 'bootstrap_progressbar'
gem 'builder'
gem 'country_select', '~> 6.0'
gem 'copyright-header', require: false
gem 'image_processing'
gem 'jbuilder' # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "geo_coord", require: "geo/coord"
gem 'leaflet-rails'
gem 'mime-types'
gem 'net-scp'
gem 'net-sftp'
gem 'net-ssh'
gem 'roo-xls' # Handle excel files
gem 'rubyzip', '~> 2.3.0' # Handle zip files
gem 'simple_form'
gem 'sprockets-rails', require: 'sprockets/railtie'
gem 'whenever', require: false # Runs scheduled jobs via cron
gem 'will_paginate'
gem 'will_paginate-bootstrap'

group :development do
  gem 'better_errors' # Better error page for Rack apps
  gem 'bullet' # Checks for n+1 queries
  gem 'binding_of_caller' # Extends features of better_errors
  gem 'meta_request' # Supporting gem for Google Chrome Rails Panel
  gem 'licensed' # Check compatibility of gem licenses
  gem 'listen'
  gem 'spring', '~> 3' # Spring speeds up development by keeping your application running in the background
  gem 'yard' # Documentation generation tool
end

group :test do
  gem 'capybara'
  gem 'capybara-selenium'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'guard-rspec'
  gem 'launchy'
  gem 'webdrivers'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'shoulda-callback-matchers'
  gem 'simplecov', require: false # Metrics for test coverage
end

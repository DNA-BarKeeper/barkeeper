# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.6.6'

gem 'rails', '5.2.4.3'

# Postgres
gem 'pg'
gem 'pg_search'

# Web server and background processing
gem 'puma'
gem 'redis' # Use Redis adapter to run Action Cable in production
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
gem 'paperclip'

# Javascript
gem 'bootstrap-multiselect_rails' # multi select boxes using bootstrap
gem 'chosen-rails' # Javascript select boxes
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
gem 'jbuilder' # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'mime-types'
gem 'net-scp'
gem 'net-sftp'
gem 'net-ssh'
gem 'roo-xls' # Handle excel files
gem 'rubyzip' # Handle zip files
gem 'simple_form'
gem 'sprockets-rails', require: 'sprockets/railtie'
gem 'whenever', require: false # Runs scheduled jobs via cron
gem 'will_paginate'
gem 'will_paginate-bootstrap'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development do
  gem 'capistrano',         require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rails',   require: false
  gem 'capistrano-rbenv',   require: false
  gem 'capistrano-sidekiq', require: false, github: 'seuros/capistrano-sidekiq'
  gem 'capistrano3-puma', require: false
  gem 'better_errors' # Better error page for Rack apps
  gem 'bullet' # Checks for n+1 queries
  gem 'binding_of_caller' # Extends features of better_errors
  gem 'meta_request' # Supporting gem for Google Chrome Rails Panel
  gem 'spring' # Spring speeds up development by keeping your application running in the background
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

source 'https://rubygems.org'

ruby '2.3.3'

gem 'rails', '5.0.0'

# Postgres
gem 'pg', '~> 0.21' # Rails does not work with pg 1.0.0 (fixed in Rails 5.1.5)
gem 'pg_search'

# Web server and background processing
gem 'puma', '~> 3.0'
gem 'redis', '~> 3.0' # Use Redis adapter to run Action Cable in production
gem 'sidekiq'
gem 'sidekiq-limit_fetch'
gem 'sinatra', :require => false # Needed to monitor sidekiq jobs

# Asset pipeline
gem 'coffee-rails', '~> 4.2' # Use CoffeeScript for .coffee assets and views
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'sass-rails', '~> 5.0' # Use SCSS for stylesheets
gem 'uglifier', '>= 1.3.0' # Use Uglifier as compressor for JavaScript assets

# Authentication & authorization
gem 'cancancan'
gem 'devise'

# External file storage
gem 'aws-sdk'
gem 'paperclip'

# Javascript
gem 'chosen-rails' # Javascript select boxes
gem 'jquery-datatables-rails', github: 'rweng/jquery-datatables-rails'
gem 'jquery-fileupload-rails'
gem 'jquery-turbolinks'
gem 'select2-rails' # Integrate Select2 Javascript library

gem 'bcrypt', '~> 3.1.7', platforms: :ruby
gem 'bio' # BioRuby
gem 'bootstrap-sass'
gem 'jbuilder', '~> 2.5' # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'mime-types'
gem 'roo-xls' # Handle excel files
gem 'rubyzip' # Handle zip files
gem 'scenic' # Adds methods for creating and managing database views
gem 'simple_form'
gem 'slim' # TODO: Used anywhere?
gem 'sprockets-rails', :require => 'sprockets/railtie'
# gem 'turbolinks' # Turbolinks makes navigating your web application faster TODO: Does not work unless first changes to js code, in particular data-tables (see http://guides.rubyonrails.org/working_with_javascript_in_rails.html#turbolinks)
gem 'whenever', require: false # Runs scheduled jobs via cron
gem 'will_paginate', '> 3.0' # TODO: Really needed?
gem 'will_paginate-bootstrap' # TODO: Really needed?

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

group :development do
  gem 'capistrano',         require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rails',   require: false
  gem 'capistrano-rbenv',   require: false
  gem 'capistrano-sidekiq', require: false, github: 'seuros/capistrano-sidekiq'
  gem 'capistrano3-puma',   require: false, github: 'seuros/capistrano-puma' # TODO: remove github once fixed version is officially deployed
  gem 'spring' # Spring speeds up development by keeping your application running in the background
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'simplecov'
  gem 'selenium-webdriver' # TODO: Replace by phantom.js
end

group :development, :test do
  gem 'better_errors'
  gem 'bullet' # Checks for n+1 queries
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'meta_request' # Supporting gem for Google Chrome Rails Panel
  gem 'poltergeist'
  gem 'rails_best_practices'
  gem 'rspec-rails'
  gem 'yard' # Documentation generation tool
end

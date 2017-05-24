source 'https://rubygems.org'
ruby '2.3.3'
gem 'rails', '5.0.0'

gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 3.0', :group => 'production'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# gem 'rack-mini-profiler', group: :development
gem 'rails_12factor', group: :production
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
#gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
gem 'populator'
gem 'bootstrap-sass'
gem 'sprockets-rails', :require => 'sprockets/railtie'
gem 'devise'
gem 'simple_form' #todo check if used anywhere, rm
gem 'bio'
gem 'paperclip', github: 'thoughtbot/paperclip'
gem 's3_direct_upload'
gem 'aws-sdk', '~> 2'
gem 'pg_search'
gem 'will_paginate', '> 3.0'
gem 'will_paginate-bootstrap'

gem 'roo'
gem 'sidekiq'
gem 'whenever', :require => false
gem 'chosen-rails'

#todo jquery is no longer a default dependency, check if these gems are still needed
gem 'jquery-rails'
gem 'jquery-turbolinks'
gem 'jquery-ui-rails'
gem 'jquery-datatables-rails', github: 'rweng/jquery-datatables-rails'
gem 'jquery-fileupload-rails'

group :development, :test do
  gem 'better_errors'
  gem 'yard'
  # check for n+1 queries:
  gem 'bullet'
  gem 'rails_best_practices'
  gem 'meta_request' # Supporting gem for Rails Panel (Google Chrome extension for Rails development)., https://github.com/dejan/rails_panel/tree/master/meta_request
  gem 'launchy'
end

# group :development do
#   # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
#   gem 'spring'
#   gem 'spring-watcher-listen', '~> 2.0.0'
# end

group :test do
  gem 'minitest'
  gem 'minitest-rails-capybara'
  gem 'minitest-reporters'
  gem 'minitest-fail-fast'
  gem 'webrat'
  gem 'simplecov'
  gem 'selenium-webdriver'
  gem 'binding_of_caller'
  gem 'rails-controller-testing'
end

# needed to monitor sidekiq jobs:
gem 'sinatra', :require => nil
gem 'slim'
gem 'mime-types'

gem 'newrelic_rpm'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
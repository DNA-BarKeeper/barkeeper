source 'https://rubygems.org'
ruby '2.3.3'
gem 'rails', '4.2.0'

#gem 'rack-mini-profiler', group: :development
gem 'rails_12factor', group: :production
gem 'pg'

gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails', '~> 2.3.0'
gem 'jquery-ui-rails'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0',          group: :doc
# gem 'spring',        group: :development
gem 'populator'
gem 'turbolinks'
gem 'jquery-turbolinks'
gem 'bootstrap-sass'
gem 'sprockets-rails', :require => 'sprockets/railtie'
gem 'devise'
gem 'simple_form' # todo check if used anywhere, rm
gem 'bio'
gem 'paperclip', github: 'thoughtbot/paperclip'
gem 'pg_search'
gem 's3_direct_upload'
gem 'aws-sdk', '< 2.0'
gem 'will_paginate', '> 3.0'
gem 'will_paginate-bootstrap'
gem 'jquery-datatables-rails', github: 'rweng/jquery-datatables-rails'
gem 'jquery-fileupload-rails'
gem 'roo'
gem 'sidekiq'
gem 'whenever', :require => false
gem 'chosen-rails'

gem 'puma', :group => 'production'

group :development, :test do
  gem 'better_errors'
  gem 'yard'
  # check for n+1 queries:
  gem 'bullet'
  gem 'rails_best_practices'
  gem 'meta_request' #Supporting gem for Rails Panel (Google Chrome extension for Rails development)., https://github.com/dejan/rails_panel/tree/master/meta_request
  gem 'launchy'
end

group :test do
  gem 'minitest'
  gem 'minitest-rails-capybara'
  gem 'minitest-reporters'
  gem 'minitest-fail-fast'
  gem 'webrat'
  gem 'simplecov'
  gem 'selenium-webdriver'
  gem 'binding_of_caller'
end


# needed to monitor sidekiq jobs:
gem 'sinatra', :require => nil
gem 'slim'
gem 'mime-types'

gem 'newrelic_rpm'

gem 'redis'
source 'https://rubygems.org'
# ruby '2.1.1'
ruby '2.2.0'
# gem 'rails', '4.1.0'
gem 'rails', '4.2.0'

gem 'rack-mini-profiler', group: :development
# gem 'rails_12factor', group: :production
gem 'pg'

gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails', '~> 2.3.0'
gem 'jquery-ui-rails'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0',          group: :doc
gem 'spring',        group: :development
gem 'populator'
gem 'turbolinks'
gem 'jquery-turbolinks'
gem 'bootstrap-sass'
gem 'sprockets-rails', :require => 'sprockets/railtie'
gem 'devise'
gem 'simple_form'
gem 'bio'
gem 'paperclip', github: 'thoughtbot/paperclip'
gem 'aws-sdk', '< 2.0'
gem 'will_paginate', '> 3.0'
gem 'will_paginate-bootstrap'
gem 'jquery-datatables-rails', github: 'rweng/jquery-datatables-rails'
gem 'jquery-fileupload-rails'
gem 'roo'
gem 'sidekiq'


group :development, :test do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'rails_apps_testing'
  gem 'rails_layout'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'webrat'

  # rm later  for replacement by Spring
  gem 'spork-rails'
  gem 'guard-spork'
  gem 'childprocess'
  gem 'guard-livereload'

end

group :test do
  gem 'selenium-webdriver'
end

# check for n+1 queries:
gem 'bullet', :group => 'development'
gem 'rails_best_practices', :group => 'development'

# needed to monitor sidekiq jobs:
gem 'sinatra', :require => nil
gem 'slim'
gem 'mime-types'
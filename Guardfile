# edited on 17.09.2014 20:09 by Kai Müller according to Rails Tutorial (Hartl),
# https://www.railstutorial.org/book/static_pages#code-about_page_content_spec:
#3.6 Advanced setup

require 'active_support/inflector'


guard 'livereload' do
  watch(%r{app/views/.+\.(erb|haml|slim)$})
  watch(%r{app/helpers/.+\.rb})
  watch(%r{public/.+\.(css|js|html)})
  watch(%r{config/locales/.+\.yml})
  # Rails Assets Pipeline
  watch(%r{(app|vendor)(/assets/\w+/(.+\.(css|js|html|png|jpg))).*}) { |m| "/assets/#{m[3]}" }
end
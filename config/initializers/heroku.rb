unless (app_name = ENV["HEROKU_APP_NAME"]).nil?
  require 'heroku-api'

  heroku  = Heroku::API.new(:api_key => ENV["HEROKU_API_KEY"])
  release = heroku.get_releases(app_name).body.last

  ENV["HEROKU_RELEASE_NAME"] = release["name"]
end
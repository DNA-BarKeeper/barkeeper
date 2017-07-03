
if ENV['HEROKU_RELEASE_VERSION']
  gbol5_app_version = ENV['HEROKU_RELEASE_VERSION']
  gbol5_app_version = gbol5_app_version.match(/^v(\d+)/)[1]
else
  gbol5_app_version = ''
end


if ENV['HEROKU_RELEASE_CREATED_AT']
  gbol5_app_release_date = ENV['HEROKU_RELEASE_CREATED_AT']
  gbol5_app_release_date = Time.zone.parse(gbol5_app_release_date)
else
  gbol5_app_release_date = ''
end
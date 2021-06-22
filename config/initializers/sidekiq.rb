Sidekiq.configure_server do |config|
  config.redis = { :password => Rails.application.credentials.redis_password }
end

Sidekiq.configure_client do |config|
  config.redis = { :password => Rails.application.credentials.redis_password }
end

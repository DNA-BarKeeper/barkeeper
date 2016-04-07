uri = URI.parse(ENV["REDISTOGO_URL"])
#todo rm ^
REDIS = Redis.new(:url => ENV['REDISTOGO_URL'])
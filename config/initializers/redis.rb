# frozen_string_literal: true

REDIS = Redis.new(url: ENV['REDIS_URL'] || '127.0.0.0') # TODO fix url in non-docker env

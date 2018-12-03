# frozen_string_literal: true

REDIS = Redis.new(host: ENV.fetch('REDIS_URL', 'localhost'))

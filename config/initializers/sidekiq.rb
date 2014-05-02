# This file will be overwritten on deployment
require "sidekiq"

if ENV["RACK_ENV"]
  namespace = "rummager-#{ENV['RACK_ENV']}"
else
  namespace = "rummager"
end

redis_config = {
  :namespace => namespace
}
if ENV['QUIRKAFLEEG_RUMMAGER_REDIS_HOST']
  redis_config[:host] = ENV['QUIRKAFLEEG_RUMMAGER_REDIS_HOST']
  redis_config[:password] = ENV['QUIRKAFLEEG_RUMMAGER_REDIS_PASSWORD']
else
  redis_config[:url] = "redis://localhost:6379/0"
end


Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end

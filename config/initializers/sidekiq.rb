require 'sidekiq/api'

redis_config = { url: ENV['REDIS_URL'] }

Sidekiq.configure_server do |config|
  config.redis = redis_config

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end

  config.server_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Server
  end

  SidekiqUniqueJobs::Server.configure(config)
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
  
  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end
end

require 'sidekiq/web'
Sidekiq::Web.app_url = '/'

schedule_file = 'config/schedule.yml'
Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file) if File.exist?(schedule_file) && Sidekiq.server?

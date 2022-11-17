# frozen_string_literal: true

require 'sidekiq'
require 'sidekiq-unique-jobs'

job_redis_url = ENV.fetch('JOB_REDIS_URL', 'redis://127.0.0.1:6379/0')

Sidekiq.configure_server do |config|
  config.on(:startup) do
    config.redis = { url: job_redis_url }
    # Load sidekiq-cron schedule using the configured redis connection
    require 'sidekiq-cron'
    Sidekiq::Cron::Job.all.each(&:destroy)

    config.client_middleware do |chain|
      chain.add SidekiqUniqueJobs::Middleware::Client
    end

    config.server_middleware do |chain|
      chain.add SidekiqUniqueJobs::Middleware::Server
    end

    SidekiqUniqueJobs::Server.configure(config)
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: job_redis_url }

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end
end

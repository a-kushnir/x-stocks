# frozen_string_literal: true

require 'sidekiq'

job_redis_url = ENV.fetch('JOB_REDIS_URL', 'redis://127.0.0.1:6379/0')

Sidekiq.configure_server do |config|
  config.on(:startup) do
    config.redis = { url: job_redis_url }
    # Load sidekiq-cron schedule using the configured redis connection
    require 'sidekiq-cron'
    Sidekiq::Cron::Job.all.each(&:destroy)
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: job_redis_url }
end

# frozen_string_literal: true

module XStocks
  # Demo Job
  class DemoJob
    include Sidekiq::Job
    sidekiq_options retry: false

    def perform(user_id)
      user = XStocks::AR::User.find(user_id)
      XStocks::DemoMailer.with(user: user).notify.deliver_now
    end
  end
end

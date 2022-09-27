# frozen_string_literal: true

require 'honeybadger'

::Honeybadger.configure do |config|
  config.api_key = ENV['HONEYBADGER_API_KEY'].presence
  config.send_data_at_exit = false
  config.env = Rails.env
  config.report_data = (config.api_key && Rails.env.production?)
end

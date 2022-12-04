# frozen_string_literal: true

require 'x_stocks/signals'

module XStocks
  # Generates SMA 50 x SMA 200 Signals
  class GenerateSignals
    include Sidekiq::Job

    sidekiq_options retry: false,
                    lock: :until_executed

    PAUSE = 3 # Limit up to 20 request per minute

    def perform
      signals = []
      XStocks::AR::Stock.random.each do |stock|
        XStocks::Signals.all.each do |detector|
          safe_exec(stock) do
            signals << detector.new(stock).detect
          end
        end
      end
      signals.compact!

      signals.reject! do |signal|
        XStocks::AR::Signal.exists?(signal.slice(:stock_id, :timestamp, :detection_method))
      end

      signals.each do |signal|
        safe_exec(signal.stock) do
          update_price(signal.stock)
        end
      end

      notify(signals.map(&:id)) if signals.any?
    end

    def safe_exec(stock)
      yield
    rescue StandardError => e
      options = { context: { symbol: stock&.symbol } }
      Honeybadger.notify(e, options)
    end

    def update_price(stock)
      XStocks::Jobs::FinnhubPriceOne.new(nil).perform(symbol: stock.symbol) { nil }
      sleep(PAUSE)
    end

    def notify(signal_ids)
      user_ids = XStocks::AR::User.where(dividend_notifications: true).pluck(:id)
      user_ids.each do |user_id|
        XStocks::NotificationMailer.with(user_id: user_id, signal_ids: signal_ids).signals_detected.deliver_now
      end
    end
  end
end

# frozen_string_literal: true

module XStocks
  # Generates SMA 50 x SMA 200 Signals
  class GenerateSignals
    include Sidekiq::Job
    sidekiq_options retry: false

    PAUSE = 2 # Limit up to 1 request per 2 seconds

    def perform
      signals = []
      XStocks::AR::Stock.random.each do |stock|
        signals << Sma50xSma200.new(stock).detect
      end
      signals.compact!

      notify(signals.map(&:id)) if signals.any?
    end

    class Sma50xSma200
      def initialize(stock)
        @stock = stock
      end

      def detect
        sma50_old, sma50_new, timestamp = sma(50)
        sma200_old, sma200_new = sma(200)

        old_state = sma50_old > sma200_old ? :buy : :sell
        new_state = sma50_new > sma200_new ? :buy : :sell
        return nil if old_state == new_state

        XStocks::AR::Signal.create(
          stock: stock,
          timestamp: Time.at(timestamp).to_datetime,
          detection_method: self.class.name.demodulize,
          value: new_state
        )
      end

      private

      # Returns the simple moving average (SMA) values
      def sma(days)
        to = DateTime.now
        from = to - (days * 1.5) # Business days -> Calendar days

        token_store.try_token do |token|
          json = Etl::Extract::Finnhub.new(data_loader, token).indicator(stock, resolution: 'D', from: from.to_i, to: to.to_i, indicator: 'sma', timeperiod: days)
          sleep(PAUSE)

          [*json['sma'].last(2), json['t'].last]
        end
      end

      def token_store
        @token_store ||= Etl::Extract::TokenStore.new(Etl::Extract::Finnhub::TOKEN_KEY)
      end

      def data_loader
        @data_loader ||= Etl::Extract::DataLoader.new
      end

      attr_reader :stock
    end

    def notify(signal_ids)
      user_ids = XStocks::AR::User.where(dividend_notifications: true).pluck(:id)
      user_ids.each do |user_id|
        XStocks::NotificationMailer.with(user_id: user_id, signal_ids: signal_ids).signals_detected.deliver_now
      end
    end
  end
end

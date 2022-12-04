# frozen_string_literal: true

module XStocks
  module Signals
    # Detects intersection of SMA 50 and SMA 200
    class Sma50XSma200 < Base
      PAUSE = 3 # Limit up to 20 request per minute

      def detect
        sma50_old, sma50_new, price, timestamp = sma(50)
        return nil if [sma50_old, sma50_new, price, timestamp].any?(&:blank?)

        sma200_old, sma200_new = sma(200)
        return nil if [sma200_old, sma200_new].any?(&:blank?)

        signal = intersection(sma50_old, sma50_new, sma200_old, sma200_new)
        create_signal(timestamp, signal, price) if signal
      end

      private

      # Returns the simple moving average (SMA) values
      def sma(days)
        to = DateTime.now
        from = to - ((days * 1.5) + 15) # Business days -> Calendar days

        token_store.try_token do |token|
          json = Etl::Extract::Finnhub.new(data_loader, token).indicator(stock, resolution: 'D', from: from.to_i, to: to.to_i, indicator: 'sma', timeperiod: days)
          sleep(PAUSE)

          [*json['sma']&.last(2), json['c']&.last, json['t']&.last]
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
  end
end

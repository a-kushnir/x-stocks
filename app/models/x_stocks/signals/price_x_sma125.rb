# frozen_string_literal: true

module XStocks
  module Signals
    # Detects intersection of Price and SMA 125
    class PriceXSma125 < Base
      PAUSE = 3 # Limit up to 20 request per minute

      def detect
        sma125_old, sma125_new, price_old, price_new, timestamp = sma(125)
        return nil if [sma125_old, sma125_new, price_old, price_new, timestamp].any?(&:blank?)

        signal = intersection(price_old, price_new, sma125_old, sma125_new)
        create_signal(timestamp, signal, price_new) if signal
      end

      private

      # Returns the simple moving average (SMA) values
      def sma(days)
        to = DateTime.now
        from = to - ((days * 1.5) + 15) # Business days -> Calendar days

        token_store.try_token do |token|
          json = Etl::Extract::Finnhub.new(data_loader, token).indicator(stock, resolution: 'D', from: from.to_i, to: to.to_i, indicator: 'sma', timeperiod: days)
          sleep(PAUSE)

          [*json['sma']&.last(2), *json['c']&.last(2), json['t']&.last]
        end
      end

      def token_store
        @token_store ||= Etl::Extract::TokenStore.new(Etl::Extract::Finnhub::TOKEN_KEY)
      end

      def data_loader
        @data_loader ||= Etl::Extract::DataLoader.new
      end
    end
  end
end


# frozen_string_literal: true

module XStocks
  module Analyze
    #  Candle Analyzer
    class Candle
      def analyze(prices, timestamps)
        prices, timestamps = delete_non_market(prices, timestamps)
        analyze_ma60(prices, timestamps)
      end

      private

      def delete_non_market(prices, timestamps)
        new_prices = []
        new_timestamps = []

        timestamps.each_with_index do |timestamp, index|
          hour = Time.at(timestamp).utc.hour
          next if hour < 13 || hour > 19

          new_prices << prices[index]
          new_timestamps << timestamps[index]
        end

        [new_prices, new_timestamps]
      end

      def analyze_ma60(prices, timestamps)
        result = []

        size = 60
        ma = Math.moving_average(prices, 60, 2)
        ma_over = nil

        prices.each_with_index do |price, index|
          ma_index = index - size + 1
          next if ma_index < 0

          new_ma_over = ma[ma_index] > price

          event =
            if ma_index > 0 && ma_over != new_ma_over
              new_ma_over ? 'Sell' : 'Buy'
            end

          result << {
            time: time(timestamps[index]),
            event: event,
            price: price,
            ma60: ma[ma_index]
          }

          ma_over = new_ma_over
        end

        result
      end

      def time(timestamp)
        zone = "America/Denver"
        datetime = Time.at(timestamp).in_time_zone(zone).to_datetime
        datetime.strftime('%Y-%m-%d %H:%M')
      end
    end
  end
end

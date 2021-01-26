# frozen_string_literal: true

module XStocks
  class Position
    # Average Dividend Rating Calculator
    class AvgDividendRating
      def initialize
        @dividend_rating = 0
        @market_value = 0
      end

      def add(dividend_rating, div_suspended, market_value)
        return if market_value.zero?

        if div_suspended
          @market_value += market_value
        elsif dividend_rating
          @dividend_rating += dividend_rating * market_value
          @market_value += market_value
        end
      end

      def value
        return nil if @market_value.zero?

        (@dividend_rating / @market_value).round(1)
      end
    end
  end
end

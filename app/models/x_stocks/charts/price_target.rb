# frozen_string_literal: true

module XStocks
  module Charts
    # Price Target Chart
    class PriceTarget
      def initialize(stock, details)
        @stock = stock
        @details = details
      end

      def data?
        details.present?
      end

      def data
        {
          low: details['low'],
          high: details['high'],
          mean: details['mean'],
          current: stock.current_price.to_f
        }
      end

      private

      attr_reader :stock, :details
    end
  end
end

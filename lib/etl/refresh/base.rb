# frozen_string_literal: true

module Etl
  module Refresh
    # Base methods for extracting and transforming data
    class Base
      def stock_message(stock)
        {
          message: "Processing #{stock.symbol} (1 out of 1)",
          percent: 0
        }
      end

      def each_stock_with_message
        stocks = XStocks::AR::Stock.random.all.to_a
        stocks.each_with_index do |stock, index|
          yield stock, {
            message: "Processing #{stock.symbol} (#{index + 1} out of #{stocks.size})",
            percent: index * 100 / stocks.length
          }
        end
      end

      def processing_message(percent)
        {
          message: 'Processing',
          percent: percent
        }
      end

      def completed_message
        {
          message: 'Completed',
          percent: 100
        }
      end
    end
  end
end

# frozen_string_literal: true

module Etl
  module Refresh
    # Base methods for extracting and transforming data
    class Base
      attr_reader :logger

      def initialize(logger)
        @logger = logger
      end

      def stock_message(stock)
        {
          message: "Processing #{stock.symbol} (1 out of 1)",
          percent: 0
        }
      end

      def each_symbol_with_message(symbols)
        symbols.each_with_index do |symbol, index|
          yield symbol, {
            message: "Processing #{symbol} (#{index + 1} out of #{symbols.size})",
            percent: index * 100 / symbols.length
          }
        end
      end

      def each_stock_with_message
        stocks = XStocks::Stock.find_all_random
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

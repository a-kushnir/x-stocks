# frozen_string_literal: true

module XStocks
  module Jobs
    # YahooStockOne Job
    class YahooStockOne < Base
      def name
        'Update stock information'
      end

      def tags
        ['Yahoo']
      end

      def perform(symbol:)
        stock = XStocks::Stock.find_by!(symbol: symbol)
        yield stock_message(stock)

        lock do |logger|
          logger.text_size_limit = nil
          Etl::Refresh::Yahoo.new(logger).daily_one_stock(stock)
        end

        yield completed_message
      end

      def arguments
        { symbol: select_tag(values: stock_values, include_blank: '') }
      end
    end
  end
end

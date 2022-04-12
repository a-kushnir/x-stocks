# frozen_string_literal: true

module XStocks
  module Jobs
    # PolygonStockOne Job
    class PolygonStockOne < Base
      def name
        'Update stock information'
      end

      def tags
        ['Polygon']
      end

      def perform(symbol:, &block)
        stock = XStocks::Stock.find_by!(symbol: symbol)
        yield stock_message(stock)

        lock do |logger|
          logger.text_size_limit = nil
          Etl::Refresh::Polygon.new(logger).weekly_one_stock(stock, immediate: true, &block)
        end

        yield completed_message
      end

      def arguments
        { symbol: select_tag(values: stock_values, include_blank: '') }
      end
    end
  end
end

# frozen_string_literal: true

module XStocks
  module Jobs
    # DividendStockOne Job
    class DividendStockOne < Base
      def name
        'Update stock dividends'
      end

      def tags
        ['Dividend.com']
      end

      def perform(symbol:)
        stock = XStocks::Stock.find_by!(symbol: symbol)
        yield stock_message(stock)

        lock do |logger|
          logger.text_size_limit = nil
          Etl::Refresh::Dividend.new(logger).weekly_one_stock(stock)
        end

        yield completed_message
      end

      def arguments
        { symbol: select_tag(values: stock_values, include_blank: '') }
      end
    end
  end
end

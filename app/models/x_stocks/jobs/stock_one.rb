# frozen_string_literal: true

module XStocks
  module Jobs
    # StockOne Job
    class StockOne < Base
      def name
        'Update stock information'
      end

      def tags
        ['Dividend.com', 'Finnhub', 'IEX Cloud', 'Yahoo']
      end

      def perform(symbol:)
        stocks = [XStocks::Stock.find_by!(symbol: symbol)]

        lock do |logger|
          logger.text_size_limit = nil

          Etl::Refresh::StockList.new.update(stocks, logger) do |stock, percent|
            yield stock_message(stock, percent: percent)
          end

          yield completed_message
        end
      end

      def arguments
        { symbol: select_tag(values: stock_values, include_blank: '') }
      end
    end
  end
end

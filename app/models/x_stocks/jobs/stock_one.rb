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

      def perform(stock_id:)
        stock = XStocks::Stock.find_by!(id: stock_id)
        yield stock_message(stock)

        lock do |logger|
          logger.text_size_limit = nil

          Etl::Refresh::Finnhub.new(logger).daily_one_stock(stock)
          yield stock_message(stock, percent: 25)

          Etl::Refresh::Yahoo.new(logger).daily_one_stock(stock)
          yield stock_message(stock, percent: 50)

          Etl::Refresh::Dividend.new(logger).weekly_one_stock(stock)
          yield stock_message(stock, percent: 75)

          Etl::Refresh::Iexapis.new(logger).weekly_one_stock(stock, immediate: true)
        end

        yield completed_message
      end

      def arguments
        [:stock_id]
      end
    end
  end
end

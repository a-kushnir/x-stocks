# frozen_string_literal: true

module XStocks
  module Jobs
    # StockList Job
    class StockList < Base
      def name
        'Update stock list information'
      end

      def tags
        ['Dividend.com', 'Finnhub', 'IEX Cloud', 'Yahoo']
      end

      def perform
        stock_ids = current_user.positions.pluck(:stock_id)
        stocks = XStocks::AR::Stock.where(id: stock_ids).all.map { |stock| XStocks::Stock.new(stock) }

        lock do |logger|
          logger.text_size_limit = nil

          Etl::Refresh::StockList.new.update(stocks, logger) do |stock, percent|
            yield stock_message(stock, percent: percent)
          end

          yield completed_message
        end
      end
    end
  end
end

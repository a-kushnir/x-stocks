# frozen_string_literal: true

require 'x_stocks/stock/lists/portfolio'
require 'x_stocks/stock/lists/watchlist'

module XStocks
  module Jobs
    # StockList Job
    class StockList < Base
      LISTS = [
        XStocks::Stock::Lists::Portfolio,
        XStocks::Stock::Lists::Watchlist
      ].freeze

      INDEX = LISTS.map { |list| [list::TYPE, list] }.to_h.freeze

      def name
        'Update stock list information'
      end

      def tags
        ['Dividend.com', 'Finnhub', 'IEX Cloud', 'Yahoo']
      end

      def perform(list:)
        stock_ids = stock_ids(list)
        stocks = XStocks::AR::Stock.where(id: stock_ids).all.map { |stock| XStocks::Stock.new(stock) }

        lock do |logger|
          logger.text_size_limit = nil

          Etl::Refresh::StockList.new.update(stocks, logger) do |stock, percent, index|
            yield stock_message(stock, percent: percent, index: index, count: stocks.count)
          end

          yield completed_message
        end
      end

      def arguments
        { list: select_tag(values: lists, include_blank: '') }
      end

      private

      def lists
        LISTS.flat_map { |list| list.new(current_user).values }
      end

      def stock_ids(list)
        type, hashid = list&.split(':')
        INDEX[type]&.new(current_user)&.stock_ids(hashid) || []
      end
    end
  end
end

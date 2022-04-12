# frozen_string_literal: true

module XStocks
  module Jobs
    # IexapisDividendsOne Job
    class IexapisDividendsOne < Base
      def name
        'Update stock dividends'
      end

      def tags
        ['IEX Cloud']
      end

      def perform(symbol:, &block)
        stock = XStocks::Stock.find_by!(symbol: symbol)
        yield stock_message(stock)

        lock do |logger|
          logger.text_size_limit = nil
          Etl::Refresh::Iexapis.new(logger).weekly_one_stock(stock, immediate: true, &block)
        end

        yield completed_message
      end

      def arguments
        { symbol: select_tag(values: stock_values, include_blank: '') }
      end
    end
  end
end

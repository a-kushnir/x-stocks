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

      def perform(stock_id:, &block)
        stock = XStocks::Stock.find_by!(id: stock_id)
        yield stock_message(stock)

        lock do |logger|
          logger.text_size_limit = nil
          Etl::Refresh::Iexapis.new(logger).weekly_one_stock(stock, immediate: true, &block)
        end

        yield completed_message
      end

      def arguments
        [:stock_id]
      end
    end
  end
end

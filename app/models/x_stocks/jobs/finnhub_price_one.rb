# frozen_string_literal: true

module XStocks
  module Jobs
    # FinnhubPriceOne Job
    class FinnhubPriceOne < Base
      def name
        'Update stock prices'
      end

      def tags
        ['Finnhub']
      end

      def perform(stock_id:, &block)
        stock = XStocks::Stock.find_by!(id: stock_id)
        yield stock_message(stock)

        lock do |logger|
          logger.text_size_limit = nil
          Etl::Refresh::Finnhub.new(logger).hourly_one_stock(stock, &block)
        end

        yield completed_message
      end

      def arguments
        [:stock_id]
      end
    end
  end
end

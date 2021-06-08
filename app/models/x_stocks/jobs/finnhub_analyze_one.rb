# frozen_string_literal: true

module XStocks
  module Jobs
    # FinnhubAnalyzeOne Job
    class FinnhubAnalyzeOne < Base
      def name
        'Stock Signals'
      end

      def tags
        ['Finnhub']
      end

      def perform(stock_id:, &block)
        stock = XStocks::Stock.find_by!(id: stock_id)
        yield stock_message(stock)

        lock do |logger|
          logger.text_size_limit = nil
          Etl::Refresh::Finnhub.new(logger).analyze_one_stock(stock, &block)
        end

        yield completed_message
      end

      def arguments
        [:stock_id]
      end
    end
  end
end

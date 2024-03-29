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

      def perform(symbol:, &block)
        stock = XStocks::Stock.find_by!(symbol: symbol)
        yield stock_message(stock)

        lock do |logger|
          logger.text_size_limit = nil
          Etl::Refresh::Finnhub.new(logger).analyze_one_stock(stock, &block)
        end

        yield completed_message
      end

      def arguments
        { symbol: select_tag(values: stock_values, include_blank: '') }
      end
    end
  end
end

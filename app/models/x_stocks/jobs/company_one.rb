# frozen_string_literal: true

module XStocks
  module Jobs
    # CompanyOne Job
    class CompanyOne < Base
      def name
        'Load company information'
      end

      def tags
        ['Finnhub', 'IEX Cloud', 'Yahoo']
      end

      def perform(symbol:, &block)
        stock = XStocks::Stock.find_by!(symbol: symbol)
        yield stock_message(stock)

        lock do |logger|
          logger.text_size_limit = nil
          Etl::Refresh::Company.new(logger).one_stock(stock, &block)
        end

        yield completed_message
      end

      def arguments
        { symbol: select_tag(values: stock_values, include_blank: '') }
      end
    end
  end
end

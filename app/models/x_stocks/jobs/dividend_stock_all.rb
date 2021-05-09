# frozen_string_literal: true

module XStocks
  module Jobs
    # DividendStockAll Job
    class DividendStockAll < Base
      def name
        'Update stock dividends'
      end

      def tags
        ['Dividend.com']
      end

      def perform(&block)
        lock do |logger|
          Etl::Refresh::Dividend.new(logger).weekly_all_stocks(&block)
        end
      end

      def interval
        7.days
      end

      def schedule
        'Weekly'
      end
    end
  end
end

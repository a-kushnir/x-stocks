# frozen_string_literal: true

module XStocks
  module Jobs
    # YahooStockAll Job
    class YahooStockAll < Base
      def name
        'Update stock information'
      end

      def tags
        ['Yahoo']
      end

      def perform(&block)
        lock do |logger|
          Etl::Refresh::Yahoo.new(logger).daily_all_stocks(&block)
        end
      end

      def interval
        1.day
      end

      def schedule
        'Daily'
      end
    end
  end
end

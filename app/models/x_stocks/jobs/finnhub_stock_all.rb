# frozen_string_literal: true

module XStocks
  module Jobs
    # FinnhubStockAll Job
    class FinnhubStockAll < Base
      def name
        'Update stock information'
      end

      def tags
        ['Finnhub']
      end

      def perform(&block)
        lock do |logger|
          Etl::Refresh::Finnhub.new(logger).daily_all_stocks(&block)
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

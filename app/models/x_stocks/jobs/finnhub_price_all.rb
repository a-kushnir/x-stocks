# frozen_string_literal: true

module XStocks
  module Jobs
    # FinnhubPriceAll Job
    class FinnhubPriceAll < Base
      def name
        'Update stock prices'
      end

      def tags
        ['Finnhub']
      end

      def perform(&block)
        lock do |logger|
          Etl::Refresh::Finnhub.new(logger).hourly_all_stocks(&block)
        end
      end

      def interval
        1.hour
      end

      def schedule
        'Hourly'
      end
    end
  end
end

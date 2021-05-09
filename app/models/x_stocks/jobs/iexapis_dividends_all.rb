# frozen_string_literal: true

module XStocks
  module Jobs
    # IexapisDividendsAll Job
    class IexapisDividendsAll < Base
      def name
        'Update stock dividends'
      end

      def tags
        ['IEX Cloud']
      end

      def perform(&block)
        lock do |logger|
          Etl::Refresh::Iexapis.new(logger).weekly_all_stocks(&block)
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

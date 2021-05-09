# frozen_string_literal: true

module XStocks
  module Jobs
    # SlickCharts Job
    class SlickCharts < Base
      def name
        'S&P 500, Nasdaq 100 and Dow Jones'
      end

      def tags
        ['SlickCharts']
      end

      def perform(&block)
        lock do |logger|
          Etl::Refresh::SlickCharts.new(logger).all_stocks(&block)
        end
      end
    end
  end
end

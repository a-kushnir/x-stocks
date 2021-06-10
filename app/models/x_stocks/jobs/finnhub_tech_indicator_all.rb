# frozen_string_literal: true

module XStocks
  module Jobs
    # FinnhubTechIndicatorAll Job
    class FinnhubTechIndicatorAll < Base
      def name
        'Technical Indicators'
      end

      def tags
        ['Finnhub']
      end

      def perform(&block)
        lock do |logger|
          Etl::Refresh::Finnhub.new(logger).tech_indicators(60, &block)
        end
      end
    end
  end
end

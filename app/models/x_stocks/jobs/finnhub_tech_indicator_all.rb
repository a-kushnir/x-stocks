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

      def perform(resolution:, &block)
        lock do |logger|
          Etl::Refresh::Finnhub.new(logger).tech_indicators(resolution, &block)
        end
      end

      def arguments
        { resolution: select_tag(values: %w[1 5 15 30 60 D W M], selected: '60') }
      end
    end
  end
end

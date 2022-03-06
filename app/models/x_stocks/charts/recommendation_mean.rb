# frozen_string_literal: true

module XStocks
  module Charts
    # Recommendation Mean Chart
    class RecommendationMean
      def initialize(mean)
        @mean = mean
      end

      def data?
        mean.present?
      end

      def data
        mean.round(2).to_f
      end

      private

      attr_reader :mean
    end
  end
end

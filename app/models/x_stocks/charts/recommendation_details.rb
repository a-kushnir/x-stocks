# frozen_string_literal: true

module XStocks
  module Charts
    # Recommendation Details Chart
    class RecommendationDetails
      def initialize(details)
        @details = details
      end

      def data?
        details.present? && details.detect { |_, v| v.detect { |i| !i.zero? } }
      end

      def data
        {
          labels: labels,
          datasets: datasets,
          min: min
        }
      end

      private

      def labels
        details.keys.map { |date| Date.parse(date).strftime('%b') }
      end

      def datasets
        [{
          label: 'Strong Sell',
          backgroundColor: '#FF333A',
          data: details.values.map { |value| value[4] }
        }, {
          label: 'Sell',
          backgroundColor: '#FFA33E',
          data: details.values.map { |value| value[3] }
        }, {
          label: 'Hold',
          backgroundColor: '#FFDC48',
          data: details.values.map { |value| value[2] }
        }, {
          label: 'Buy',
          backgroundColor: '#00C073',
          data: details.values.map { |value| value[1] }
        }, {
          label: 'Strong Buy',
          backgroundColor: '#008F88',
          data: details.values.map { |value| value[0] }
        }]
      end

      def min
        details.values.map(&:sum).max / 10
      rescue StandardError
        1
      end

      attr_reader :details
    end
  end
end

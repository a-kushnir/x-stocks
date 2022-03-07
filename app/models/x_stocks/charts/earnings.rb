# frozen_string_literal: true

module XStocks
  module Charts
    # Earnings Chart
    class Earnings
      def initialize(earnings)
        @earnings = earnings
      end

      def data?
        earnings.present?
      end

      def data
        {
          labels: earnings.map { |e| "Q#{e['quarter']} #{e['year']}" },
          estimate: earnings.map { |e| e['eps_estimate'] },
          actual: earnings.map { |e| e['eps_actual'] }
        }
      end

      def render(width:, height:)
        ChartTag.for('earnings', width: width, height: height, data: data)
      end

      private

      attr_reader :earnings
    end
  end
end

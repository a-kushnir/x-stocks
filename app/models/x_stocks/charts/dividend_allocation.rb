# frozen_string_literal: true

require 'x_stocks/charts/chart_tag'

module XStocks
  module Charts
    # Dividend Allocation Chart
    class DividendAllocation
      def initialize(positions, stocks_by_id)
        @positions = positions
        @stocks_by_id = stocks_by_id
      end

      def data
        positions = @positions.reject { |position| (position.est_annual_income || 0).zero? }
        positions = positions.sort_by(&:est_annual_income).reverse
        values = positions.map { |position| position.est_annual_income.to_f }
        labels = positions.map { |position| @stocks_by_id[position.stock_id].symbol }

        { labels: labels, values: values }
      end

      def render(width:, height:)
        ChartTag.for('allocation', width: width, height: height, data: data)
      end

      private

      attr_reader :positions, :stocks_by_id
    end
  end
end

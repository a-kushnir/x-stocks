# frozen_string_literal: true

module XStocks
  module Charts
    # Stock Allocation Chart
    class StockAllocation
      def initialize(positions, stocks_by_id)
        @positions = positions
        @stocks_by_id = stocks_by_id
      end

      def data
        positions = @positions.reject { |position| (position.market_value || 0).zero? }
        positions = positions.sort_by(&:market_value).reverse
        values = positions.map { |position| position.market_value.to_f }
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

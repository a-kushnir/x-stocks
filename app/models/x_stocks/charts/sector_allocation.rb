# frozen_string_literal: true

module XStocks
  module Charts
    # Sector Allocation Chart
    class SectorAllocation
      def initialize(positions, stocks_by_id)
        @positions = positions
        @stocks_by_id = stocks_by_id
      end

      def data
        sectors = {}
        positions = @positions.reject { |pos| (pos.market_value || 0).zero? }
        positions.each do |position|
          stock = @stocks_by_id[position.stock_id]
          sector = sectors[stock.sector] ||= { sector: stock.sector, value: 0, symbols: [] }
          sector[:value] += position.market_value
          sector[:symbols] << stock.symbol
        end
        sectors = sectors.values
        sectors = sectors.sort_by { |sector| -sector[:value] }
        values = sectors.map { |sector| sector[:value].to_f }
        labels = sectors.map { |sector| sector[:sector] }
        symbols = sectors.map { |sector| sector[:symbols].join(', ') }

        { labels: labels, symbols: symbols, values: values }
      end

      def render(width:, height:)
        ChartTag.for('allocation', width: width, height: height, data: data)
      end

      private

      attr_reader :positions, :stocks_by_id
    end
  end
end

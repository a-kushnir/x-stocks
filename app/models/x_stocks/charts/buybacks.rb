# frozen_string_literal: true

module XStocks
  module Charts
    # Buybacks Chart
    class Buybacks
      def initialize(financials)
        @financials = financials.first(24).reverse
      end

      def data?
        financials.count > 2
      end

      def data
        {
          labels: financials.map { |f| "#{f.fiscal_period} #{f.fiscal_year}" },
          values: financials.map { |f| f.common_stock_shares_outstanding }
        }
      end

      def render(width:, height:)
        ChartTag.for('buybacks', width: width, height: height, data: data)
      end

      private

      attr_reader :financials
    end
  end
end

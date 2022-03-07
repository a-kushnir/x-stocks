# frozen_string_literal: true

module XStocks
  module Charts
    # Financials Chart
    class Financials
      def initialize(stock, details)
        @stock = stock
        @details = details
      end

      def data?
        details.present?
      end

      def data
        {
          labels: details.map { |e| e['quarter'] ? "Q#{e['quarter']} #{e['year']}" : e['year'] },
          revenue: details.map { |e| e['revenue'] },
          earnings: details.map { |e| e['earnings'] },
          shares: stock.outstanding_shares
        }
      end

      def render(width:, height:)
        ChartTag.for('financials', width: width, height: height, data: data)
      end

      private

      attr_reader :stock, :details
    end
  end
end

# frozen_string_literal: true

module XStocks
  module Charts
    # Monthly Dividend Chart
    class MonthlyDividend
      def initialize(summary)
        @summary = summary
      end

      def data
        {
          labels: month_names,
          datasets: [{
            data: summary[:month_amounts],
            backgroundColor: Array.new(12, '#9DC3E6')
          }]
        }
      end

      def render(width:, height:)
        ChartTag.for('monthly-amounts', width: width, height: height, data: data)
      end

      private

      def month_names
        ::Dividend.new.months.map.with_index do |month, index|
          index.zero? || index == 11 ? month.strftime("%b'%y") : month.strftime('%b')
        end
      end

      attr_reader :summary
    end
  end
end

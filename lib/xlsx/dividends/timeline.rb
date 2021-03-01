# frozen_string_literal: true

module XLSX
  # Generates Dividend workbook
  class Dividends
    # Generates Dividend Timeline worksheet
    class Timeline
      def initialize(freeze: XLSX::Worksheet::Freeze.new,
                     styles: XLSX::Worksheet::Styles.new)
        @freeze = freeze
        @styles = styles
      end

      def generate(package, positions)
        package.workbook.add_worksheet(name: 'Dividends Timeline') do |sheet|
          freeze.generate(sheet, row: 1)
          styles.generate(sheet)

          div = ::Dividend.new
          timeline = div.timeline(positions)

          sheet.add_row header_row, style: header_styles

          positions = positions.index_by(&:stock_id)
          timeline.each do |data|
            sheet.add_row data_row(div, data, positions[data[:stock].id]), style: data_styles
          end

          sheet.add_row footer_row(timeline), style: footer_styles

          sheet.column_widths(*column_widths)
        end
      end

      private

      def header_row
        ['Symbol', 'Yield', 'Safety', 'Payment Date', 'Ex Date', 'Shares', 'Amount per Share', 'Total Amount']
      end

      def header_styles
        styles[:header, [:header_right] * 7]
      end

      def data_row(_div, data, position)
        stock = XStocks::Stock.new(position.stock)

        [
          stock.symbol,
          stock.est_annual_dividend_pct ? stock.est_annual_dividend_pct / 100 : nil,
          stock.dividend_rating ? (stock.dividend_rating * 20).to_i : nil,
          data[:payment_date],
          data[:ex_date],
          position.shares,
          data[:amount],
          data[:amount] * position.shares
        ]
      end

      def data_styles
        styles[:normal, :percent, :normal, [:date] * 2, :normal, :money5, :money]
      end

      def footer_row(timeline)
        [[nil] * 6, 'Total', timeline.map { |data| data[:amount] }.sum].flatten
      end

      def footer_styles
        styles[[:header_right] * 7, :header_money, [:header_right] * 6]
      end

      def column_widths
        [[10] * 3, [13] * 3, 15, 13].flatten
      end

      attr_reader :freeze, :styles
    end
  end
end

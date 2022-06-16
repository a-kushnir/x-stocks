# frozen_string_literal: true

module XLSX
  # Generates Dividend workbook
  class Dividends
    # Generates Dividend Timeline worksheet
    class Timeline
      delegate :t, to: :@i18n

      def initialize(freeze: XLSX::Worksheet::Freeze.new,
                     styles: XLSX::Worksheet::Styles.new,
                     i18n: I18n)
        @freeze = freeze
        @styles = styles
        @i18n = i18n
      end

      def generate(package, positions)
        package.workbook.add_worksheet(name: 'Dividends Timeline') do |sheet|
          freeze.generate(sheet, row: 1)
          styles.generate(sheet)

          div = ::Dividend.new
          timeline = div.timeline(positions)

          sheet.add_row header_row, style: header_styles

          @positions = positions.index_by(&:stock_id)
          timeline.each do |data|
            sheet.add_row data_row(div, data), style: data_styles
          end

          sheet.add_row footer_row(timeline), style: footer_styles

          sheet.column_widths(*column_widths)
        end
      end

      private

      def position(data)
        positions[data[:stock].id]
      end

      def header_row
        [
          t('dividends.columns.symbol'),
          t('dividends.columns.company'),
          t('dividends.columns.est_yield_pct'),
          t('dividends.columns.div_safety'),
          'Payment Date',
          'Ex Date',
          'Shares',
          'Amount per Share',
          'Total Amount'
        ]
      end

      def header_styles
        styles[[:header] * 2, [:header_right] * 7]
      end

      def data_row(_div, data)
        position = position(data)
        stock = XStocks::Stock.new(position.stock)

        [
          stock.symbol,
          stock.company_name,
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
        styles[[:normal] * 2, :percent, :normal, [:date] * 2, :normal, :money5, :money]
      end

      def footer_row(timeline)
        total_amount = timeline.sum { |data| data[:amount] * position(data).shares }
        [[nil] * 7, 'Total', total_amount].flatten
      end

      def footer_styles
        styles[[:header] * 7, :header_right, :header_money]
      end

      def column_widths
        [10, 25, [10] * 2, [13] * 3, 15, 13].flatten
      end

      attr_reader :freeze, :styles, :positions
    end
  end
end

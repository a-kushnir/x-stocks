# frozen_string_literal: true

module XLSX
  # Generates Dividend workbook
  class Dividends
    # Generates Dividend Calendar worksheet
    class Calendar
      def initialize(freeze: XLSX::Worksheet::Freeze.new,
                     styles: XLSX::Worksheet::Styles.new)
        @freeze = freeze
        @styles = styles
      end

      def generate(package, positions)
        positions = positions.sort_by { |position| position.stock.symbol }

        package.workbook.add_worksheet(name: 'Dividend Calendar') do |sheet|
          freeze.generate(sheet, row: 1)
          styles.generate(sheet)

          div = ::Dividend.new
          months = Array.new(12, 0.to_d)

          sheet.add_row header_row(div.months), style: header_styles

          positions.each do |position|
            sheet.add_row data_row(div, months, position), style: data_styles
          end

          sheet.add_row footer_row(months), style: footer_styles

          sheet.column_widths(*column_widths)
        end
      end

      private

      def header_row(months)
        month_names = []
        edge_months = [months.first, months.last]

        months.each do |month|
          month_names << (edge_months.include?(month) ? month.strftime("%b'%y") : month.strftime('%b'))
        end

        ['Symbol', 'Yield', 'Safety', month_names, 'Total'].flatten
      end

      def header_styles
        styles[:header, [:header_right] * 15]
      end

      def data_row(div, months, position)
        stock = XStocks::Stock.new(position.stock)
        div_suspended = stock.div_suspended?
        estimate = div.estimate(stock)

        row = [
          stock.symbol,
          if div_suspended
            'Suspended'
          else
            stock.est_annual_dividend_pct ? stock.est_annual_dividend_pct / 100 : nil
          end,
          stock.dividend_rating ? (stock.dividend_rating * 20).to_i : nil
        ]

        div.months.each_with_index do |month, index|
          month_est = estimate ? estimate.detect { |e| e[:month] == month } : nil
          amount = month_est ? month_est[:amount] * position.shares : nil
          months[index] += amount if amount
          row << amount
        end

        row << (estimate ? estimate.map { |e| e[:amount] }.sum * position.shares : nil)

        row
      end

      def data_styles
        styles[:normal, :percent, :normal, [:money] * 13]
      end

      def footer_row(months)
        [[nil] * 2, 'Total', months, months.sum].flatten
      end

      def footer_styles
        styles[[:header_right] * 3, [:header_money] * 13]
      end

      def column_widths
        [[10] * 3, [13] * 13].flatten
      end

      attr_reader :freeze, :styles
    end
  end
end

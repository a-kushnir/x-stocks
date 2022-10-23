# frozen_string_literal: true

module XLSX
  # Generates Dividend workbook
  class Dividends
    # Generates Dividend Calendar worksheet
    class Calendar
      delegate :t, to: :@i18n

      def initialize(freeze: XLSX::Worksheet::Freeze.new,
                     styles: XLSX::Worksheet::Styles.new,
                     i18n: I18n)
        @freeze = freeze
        @styles = styles
        @i18n = i18n
      end

      def generate(package, positions)
        positions = positions.sort_by { |position| position.stock.symbol }

        package.workbook.add_worksheet(name: 'Dividend Calendar') do |sheet|
          freeze.generate(sheet, row: 1)
          styles.generate(sheet)

          sheet.add_row header_row(DividendCalculator.new.months), style: header_styles

          months = Array.new(12, BigDecimal('0'))
          positions.each do |position|
            sheet.add_row data_row(months, position), style: data_styles
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

        [
          t('dividends.columns.symbol'),
          t('dividends.columns.company'),
          t('dividends.columns.est_yield_pct'),
          t('dividends.columns.div_safety'),
          *month_names,
          'Total'
        ]
      end

      def header_styles
        styles[[:header] * 2, [:header_right] * 15]
      end

      def data_row(months, position)
        stock = XStocks::Stock.new(position.stock)
        div_suspended = stock.div_suspended?

        calculator = DividendCalculator.new
        estimate = calculator.estimate(stock, date_range: calculator.date_range)

        row = [
          stock.symbol,
          stock.company_name,
          est_annual_dividend_pct(stock, div_suspended),
          dividend_rating(stock)
        ]

        amounts = calculator.months.map.with_index do |month, index|
          amount = amount(estimate, month, position)&.round(2)
          months[index] += amount if amount
          amount
        end

        row += amounts
        row << amounts.sum(&:to_d)

        row
      end

      def est_annual_dividend_pct(stock, div_suspended)
        if div_suspended
          'Sus.'
        elsif stock.est_annual_dividend_pct
          stock.est_annual_dividend_pct / 100
        end
      end

      def dividend_rating(stock)
        (stock.dividend_rating * 20).to_i if stock.dividend_rating
      end

      def amount(estimate, month, position)
        return unless estimate

        amount = estimate.select { |e| e.pay_date.at_beginning_of_month == month }.sum(&:amount)
        amount * position.shares unless amount.zero?
      end

      def data_styles
        styles[[:normal] * 2, :percent, :normal, [:money] * 13]
      end

      def footer_row(months)
        [[nil] * 3, 'Total', months, months.sum].flatten
      end

      def footer_styles
        styles[[:header] * 3, :header_right, [:header_money] * 13]
      end

      def column_widths
        [10, 25, [10] * 2, [13] * 13].flatten
      end

      attr_reader :freeze, :styles
    end
  end
end

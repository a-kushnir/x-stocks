# frozen_string_literal: true

module XLSX
  # Generates Positions workbook
  class Positions
    # Generates My Positions worksheet
    class Worksheet
      def initialize(freeze: XLSX::Worksheet::Freeze.new,
                     styles: XLSX::Worksheet::Styles.new)
        @freeze = freeze
        @styles = styles
      end

      def generate(package, positions)
        positions = positions.sort_by { |position| position.stock.symbol }

        package.workbook.add_worksheet(name: 'My Positions') do |sheet|
          freeze.generate(sheet, row: 1)
          styles.generate(sheet)

          market_value = positions.sum(&:market_value)

          sheet.add_row header_row, style: header_styles

          positions.each do |position|
            sheet.add_row data_row(position, market_value), style: data_styles
          end

          sheet.add_row footer_row(positions), style: footer_styles

          sheet.column_widths(*column_widths)
        end
      end

      private

      def header_row
        ['Symbol', 'Shares', 'Average Price', 'Market Price', 'Total Cost', 'Market Value', 'Gain/Loss', 'Gain/Loss %', 'Annual Dividend', 'Diversity %']
      end

      def header_styles
        styles[:header, [:header_right] * 9]
      end

      def data_row(position, market_value)
        [
          position.stock.symbol,
          position.shares,
          position.average_price,
          position.market_price,
          position.total_cost,
          position.market_value,
          position.gain_loss,
          safe_exec { position.gain_loss_pct / 100 },
          position.est_annual_income,
          safe_exec { position.market_value / market_value }
        ]
      end

      def data_styles
        styles[:normal, :normal, [:money] * 5, :percent, :money, :percent]
      end

      def footer_row(positions)
        market_value = positions.sum { |p| p.market_value.to_d }
        total_cost = positions.sum { |p| p.total_cost.to_d }
        gain_loss = positions.sum { |p| p.gain_loss.to_d }

        [
          [nil] * 3,
          'Total',
          total_cost,
          market_value,
          gain_loss,
          safe_exec { gain_loss / total_cost },
          positions.sum { |p| p.est_annual_income.to_d },
          1
        ].flatten
      end

      def footer_styles
        styles[[:header_right] * 4, [:header_money] * 3, :header_percent, :header_money, :header_percent]
      end

      def column_widths
        [[10] * 2, [15] * 8].flatten
      end

      def safe_exec
        yield
      rescue StandardError
        nil
      end

      attr_reader :freeze, :styles
    end
  end
end

# frozen_string_literal: true

module XLSX
  # Generates Positions workbook
  class Positions
    # Generates My Positions worksheet
    class Worksheet
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

        package.workbook.add_worksheet(name: t('positions.pages.portfolio')) do |sheet|
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
        [
          t('positions.columns.symbol'),
          t('positions.columns.shares'),
          t('positions.columns.average_price'),
          t('positions.columns.market_value'),
          t('positions.columns.total_cost'),
          t('positions.columns.market_value'),
          t('positions.columns.total_return'),
          t('positions.columns.total_return_pct'),
          t('positions.columns.annual_div'),
          t('positions.columns.diversity_pct')
        ]
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

# frozen_string_literal: true

module XLSX
  module Worksheet
    # Contains XLSX styles
    class Styles
      BASE_FORMAT = { font_name: 'Calibri' }.freeze
      HEADER_FORMAT = { bg_color: 'F2F2F2', b: true }.freeze
      US_DOLLAR_2_DECIMAL = { num_fmt: 44 }.freeze   # Accounting: 44
      US_DOLLAR_5_DECIMAL = { format_code: '$* #,##0.00???' }.freeze
      PERCENT_2_DECIMAL = { num_fmt: 10 }.freeze     # 0 Decimal: 9, 2 Decimal: 10
      ALIGN_RIGHT = { alignment: { horizontal: :right } }.freeze
      DATE_FORMAT = { format_code: 'mmm dd, yyyy' }.freeze

      def generate(sheet)
        @styles = {
          normal: add_style(sheet, BASE_FORMAT),
          percent: add_style(sheet, BASE_FORMAT, PERCENT_2_DECIMAL, ALIGN_RIGHT),
          money: add_style(sheet, BASE_FORMAT, US_DOLLAR_2_DECIMAL, ALIGN_RIGHT),
          money5: add_style(sheet, BASE_FORMAT, US_DOLLAR_5_DECIMAL, ALIGN_RIGHT),
          date: add_style(sheet, BASE_FORMAT, DATE_FORMAT, ALIGN_RIGHT),
          header: add_style(sheet, BASE_FORMAT, HEADER_FORMAT),
          header_money: add_style(sheet, BASE_FORMAT, HEADER_FORMAT, US_DOLLAR_2_DECIMAL, ALIGN_RIGHT),
          header_right: add_style(sheet, BASE_FORMAT, HEADER_FORMAT, ALIGN_RIGHT),
          header_percent: add_style(sheet, BASE_FORMAT, HEADER_FORMAT, PERCENT_2_DECIMAL, ALIGN_RIGHT)
        }
      end

      def [](*keys)
        keys.flatten.map do |key|
          style = @styles[key]
          raise "Style #{key.inspect} doesn't exist" unless style

          style
        end
      end

      private

      def add_style(sheet, *styles)
        hash = styles.count == 1 ? styles[0].dup : {}.merge(*styles)
        sheet.styles.add_style hash
      end
    end
  end
end

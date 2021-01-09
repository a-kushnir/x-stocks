# frozen_string_literal: true

module Xlsx
  class Base
    BASE_FORMAT = { font_name: 'Calibri' }.freeze
    HEADER_FORMAT = { bg_color: 'F2F2F2', b: true }.freeze
    US_DOLLAR_2_DECIMAL = { num_fmt: 44 }.freeze   # Accounting: 44
    PERCENT_2_DECIMAL = { num_fmt: 10 }.freeze     # 0 Decimal: 9, 2 Decimal: 10
    ALIGN_RIGHT = { alignment: { horizontal: :right } }.freeze

    protected

    def add_styles(sheet)
      {
        normal: add_style(sheet, BASE_FORMAT),
        percent: add_style(sheet, BASE_FORMAT, PERCENT_2_DECIMAL),
        money: add_style(sheet, BASE_FORMAT, US_DOLLAR_2_DECIMAL),
        header: add_style(sheet, BASE_FORMAT, HEADER_FORMAT),
        header_money: add_style(sheet, BASE_FORMAT, HEADER_FORMAT, US_DOLLAR_2_DECIMAL),
        header_right: add_style(sheet, BASE_FORMAT, HEADER_FORMAT, ALIGN_RIGHT),
        header_percent: add_style(sheet, BASE_FORMAT, HEADER_FORMAT, PERCENT_2_DECIMAL)
      }
    end

    def add_style(sheet, *styles)
      hash = styles.count == 1 ? styles[0] : styles[0].merge(*styles[1..-1])
      sheet.styles.add_style hash
    end
  end
end

# frozen_string_literal: true

module Xlsx
  class Dividends < Base
    def generate(file_name, positions)
      positions = positions.sort_by { |position| position.stock.symbol }

      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'My Dividends') do |sheet|
          sheet.sheet_view.pane do |pane|
            pane.top_left_cell = 'A2'
            pane.state = :frozen_split
            pane.y_split = 1
            pane.x_split = 0
            pane.active_pane = :bottom_right
          end

          styles = add_styles(sheet)

          div = ::Dividend.new
          months = Array.new(12, 0.to_d)

          sheet.add_row header_row(div.months), style: header_style(styles)

          positions.each do |position|
            sheet.add_row data_row(div, months, position, div.estimate(position.stock)), style: data_style(styles)
          end

          sheet.add_row footer_row(months), style: footer_style(styles)

          sheet.column_widths(*[10, 10, 10, Array.new(13, 13)].flatten)
        end

        package.serialize(file_name)
      end
    end

    private

    def header_row(months)
      month_names = []
      months.each_with_index do |month, index|
        month_names << (index.zero? || index == 11 ? month.strftime("%b'%y") : month.strftime('%b'))
      end

      ['Symbol', 'Yield', 'Safety', month_names, 'Total'].flatten
    end

    def header_style(styles)
      [styles[:header], Array.new(15, styles[:header_right])].flatten
    end

    def data_row(div, months, position, est)
      div_suspended = position.stock.div_suspended?

      row = [
        position.stock.symbol,
        if div_suspended
          'Suspended'
        else
          begin
                                                position.stock.est_annual_dividend_pct / 100
          rescue StandardError
            nil
                                              end
        end,
        begin
          (position.stock.dividend_rating * 20).to_i
        rescue StandardError
          nil
        end
      ]

      div.months.each_with_index do |month, index|
        amount = begin
                   est.detect { |e| e[:month] == month }&.dig(:amount) * position.shares
                 rescue StandardError
                   nil
                 end
        months[index] += amount if amount
        row << amount
      end

      begin
        row << est.map { |e| e[:amount] }.sum * position.shares
      rescue StandardError
        nil
      end
      row
    end

    def data_style(styles)
      [styles[:normal], styles[:percent], styles[:normal], Array.new(13, styles[:money])].flatten
    end

    def footer_row(months)
      ['', '', 'Total', months, months.sum].flatten
    end

    def footer_style(styles)
      [Array.new(3, styles[:header_right]), Array.new(13, styles[:header_money])].flatten
    end
  end
end

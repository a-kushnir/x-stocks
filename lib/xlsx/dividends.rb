module Xlsx
  class Dividends < Base

    def generate(file_name, positions)
      positions = positions.sort_by { |position| position.stock.symbol }

      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'My Dividends') do |sheet|

          sheet.sheet_view.pane do |pane|
            pane.top_left_cell = "A2"
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

          sheet.column_widths *[10, 10, 10, Array.new(13, 13)].flatten
        end

        package.serialize(file_name)
      end
    end

    private

    def header_row(months)
      month_names = []
      months.each_with_index do |month, index|
        month_names << (index == 0 || index == 11 ? month.strftime("%b'%y") : month.strftime('%b'))
      end

      ['Symbol', 'Yield', 'Safety', month_names, 'Total'].flatten
    end

    def header_style(s)
      [s[:header], Array.new(15, s[:header_right])].flatten
    end

    def data_row(div, months, position, est)
      div_suspended = position.stock.div_suspended?

      row = [
          position.stock.symbol,
          div_suspended ? 'Suspended' : (position.stock.est_annual_dividend_pct / 100 rescue nil),
          ((position.stock.dividend_rating * 20).to_i rescue nil),
      ]

      div.months.each_with_index do |month, index|
        amount = est.detect {|e| e[:month] == month}&.dig(:amount) * position.shares rescue nil
        months[index] += amount if amount
        row << amount
      end

      row << est.map {|e| e[:amount] }.sum * position.shares rescue nil
      row
    end

    def data_style(s)
      [s[:normal], s[:percent], s[:normal], Array.new(13, s[:money])].flatten
    end

    def footer_row(months)
      ['', '', 'Total', months, months.sum].flatten
    end

    def footer_style(s)
      [Array.new(3, s[:header_right]), Array.new(13, s[:header_money])].flatten
    end

  end
end

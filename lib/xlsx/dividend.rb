module Xlsx
  class Dividend

    def generate(file_name, positions)
      positions = positions.sort_by { |position| position.stock.symbol }

      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(:name => "My Dividends") do |sheet|

          div = ::Dividend.new
          months = Array.new(12, 0.to_d)

          sheet.add_row header_row(div.months)

          positions.each do |position|
            sheet.add_row data_row(div, months, position, div.estimate(position.stock))
          end

          sheet.add_row footer_row(months)
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

    def data_row(div, months, position, est)
      row = [
          position.stock.symbol,
          position.stock.est_annual_dividend_pct,
          ((position.stock.dividend_rating * 20).to_i rescue nil),
      ]

      div.months.each_with_index do |month, index|
        amount = est.detect {|e| e[:month] == month}&.dig(:amount) * position.shares rescue nil
        months[index] += amount if amount
        row << amount
      end

      row << est.map {|e| e[:amount] }.sum * position.shares rescue nil
    end

    def footer_row(months)
      ['', '', 'Total', months, months.sum].flatten
    end

  end
end

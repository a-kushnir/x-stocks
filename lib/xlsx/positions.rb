# frozen_string_literal: true

module Xlsx
  class Positions < Base
    def generate(file_name, positions)
      positions = positions.sort_by { |position| position.stock.symbol }

      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'My Positions') do |sheet|
          sheet.sheet_view.pane do |pane|
            pane.top_left_cell = 'A2'
            pane.state = :frozen_split
            pane.y_split = 1
            pane.x_split = 0
            pane.active_pane = :bottom_right
          end

          styles = add_styles(sheet)

          market_value = positions.sum(&:market_value)

          sheet.add_row header_row, style: header_style(styles)

          positions.each do |position|
            sheet.add_row data_row(position, market_value), style: data_style(styles)
          end

          sheet.add_row footer_row(positions), style: footer_style(styles)

          sheet.column_widths(*[10, 10, Array.new(8, 15)].flatten)
        end

        package.serialize(file_name)
      end
    end

    private

    def header_row
      ['Symbol', 'Shares', 'Average Price', 'Market Price', 'Total Cost', 'Market Value', 'Gain/Loss', 'Gain/Loss %', 'Annual Dividend', 'Diversity %']
    end

    def header_style(styles)
      [styles[:header], Array.new(9, styles[:header_right])].flatten
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
        begin
          position.gain_loss_pct / 100
        rescue StandardError
          nil
        end,
        position.est_annual_income,
        begin
          position.market_value / market_value
        rescue StandardError
          nil
        end
      ]
    end

    def data_style(styles)
      [styles[:normal], styles[:normal], Array.new(5, styles[:money]), styles[:percent], styles[:money], styles[:percent]].flatten
    end

    def footer_row(positions)
      market_value = positions.sum { |p| p.market_value.to_d }
      total_cost = positions.sum { |p| p.total_cost.to_d }
      gain_loss = positions.sum { |p| p.gain_loss.to_d }

      [
        Array.new(3, ''),
        'Total',
        total_cost,
        market_value,
        gain_loss,
        begin
          gain_loss / total_cost
        rescue StandardError
          nil
        end,
        positions.sum { |p| p.est_annual_income.to_d },
        1
      ].flatten
    end

    def footer_style(styles)
      [
        Array.new(4, styles[:header_right]),
        Array.new(3, styles[:header_money]),
        styles[:header_percent], styles[:header_money], styles[:header_percent]
      ].flatten
    end
  end
end

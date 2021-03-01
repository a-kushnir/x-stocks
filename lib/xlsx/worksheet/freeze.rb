# frozen_string_literal: true

module XLSX
  module Worksheet
    # Freezes rows and columns in XLSX file
    class Freeze
      def generate(sheet, row: 0, column: 0)
        sheet.sheet_view.pane do |pane|
          pane.top_left_cell = "#{('A'.ord + column).chr}#{row + 1}"
          pane.state = :frozen_split
          pane.y_split = row
          pane.x_split = column
          pane.active_pane = :bottom_right
        end
      end
    end
  end
end

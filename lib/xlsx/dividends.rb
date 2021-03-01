# frozen_string_literal: true

require 'xlsx/dividends/calendar'
require 'xlsx/dividends/timeline'

module XLSX
  # Generates Dividend workbook
  class Dividends
    def generate(file_name, positions)
      Axlsx::Package.new do |package|
        XLSX::Dividends::Calendar.new.generate(package, positions)
        XLSX::Dividends::Timeline.new.generate(package, positions)

        package.serialize(file_name)
      end
    end
  end
end

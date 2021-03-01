# frozen_string_literal: true

module XLSX
  # Generates Positions workbook
  class Positions
    def generate(file_name, positions)
      Axlsx::Package.new do |package|
        XLSX::Positions::Worksheet.new.generate(package, positions)

        package.serialize(file_name)
      end
    end
  end
end

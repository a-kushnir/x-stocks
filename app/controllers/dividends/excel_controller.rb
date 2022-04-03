# frozen_string_literal: true

module Dividends
  # Controller to provide dividend information for user's portfolio
  class ExcelController < ApplicationController
    def index
      @positions = XStocks::AR::Position
                   .where(user: current_user)
                   .where.not(shares: nil)
                   .all
      return unless stale?(@positions)

      @positions = @positions.to_a

      generate_xlsx
    end

    private

    def generate_xlsx
      send_tmp_file('Dividends.xlsx') do |file_name|
        XLSX::Dividends.new.generate(file_name, @positions)
      end
    end
  end
end

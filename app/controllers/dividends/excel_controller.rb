# frozen_string_literal: true

module Dividends
  # Excel representation of user portfolio dividends
  class ExcelController < ApplicationController
    def index
      return unless stale?(positions)

      send_tmp_file('Dividends.xlsx') do |file_name|
        XLSX::Dividends.new.generate(file_name, positions.to_a)
      end
    end

    private

    def positions
      @positions ||= current_user.positions.with_shares.all
    end
  end
end

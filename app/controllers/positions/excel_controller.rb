# frozen_string_literal: true

module Positions
  # Excel representation of user portfolio positions
  class ExcelController < ApplicationController
    def index
      return unless stale?(positions)

      send_tmp_file('Positions.xlsx') do |file_name|
        XLSX::Positions.new.generate(file_name, positions.to_a)
      end
    end

    private

    def positions
      @positions ||= current_user.positions.with_shares.all
    end
  end
end

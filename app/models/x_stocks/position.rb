# frozen_string_literal: true

module XStocks
  # Position Business Model
  class Position
    include XStocks::Position::Calculator
    include XStocks::Position::Summary

    def initialize(position_ar_class: XStocks::AR::Position)
      @position_ar_class = position_ar_class
    end

    def save(position)
      remove_zero_numbers(position)
      calculate_position_prices(position)
      calculate_position_dividends(position)

      if position.shares.blank? && position.note.blank?
        position.destroy
      else
        position.save
      end
    end

    private

    def remove_zero_numbers(position)
      position.shares = nil if position.shares&.zero?
      position.average_price = nil if position.average_price&.zero?
    end

    attr_reader :position_ar_class
  end
end

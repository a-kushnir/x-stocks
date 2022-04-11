# frozen_string_literal: true

require_relative 'number_delta'

module DataTable
  module Formats
    # Formats value as a number
    class Direction < NumberDelta
      def align
        :center
      end

      def format(value)
        if value.to_i.zero?
          nil
        elsif value == -1
          '-'
        elsif value == 1
          '+'
        elsif value > 1
          "+#{value}"
        else
          value
        end
      end
    end
  end
end

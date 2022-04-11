# frozen_string_literal: true

require_relative 'number'

module DataTable
  module Formats
    # Formats value as a number
    class Number2 < Number
      def format(value)
        number_with_precision(value, delimiter: ',', strip_insignificant_zeros: true, precision: 2) if value.is_a?(Numeric)
      end
    end
  end
end

# frozen_string_literal: true

require_relative 'number'

module DataTable
  module Formats
    # Formats value as a percent number
    class PercentOrWarning2 < Number
      def format(value)
        value.is_a?(Numeric) ? number_to_percentage(value, precision: 2) : value
      end

      def style(value)
        'warning' unless value.is_a?(Numeric)
      end
    end
  end
end

# frozen_string_literal: true

require_relative 'number_delta'

module DataTable
  module Formats
    # Formats value as a percent number
    class PercentDelta1 < NumberDelta
      def format(value)
        return value if value.blank?

        result = number_to_percentage(value, precision: 1)
        value > 0 ? "+#{result}" : result
      end
    end
  end
end

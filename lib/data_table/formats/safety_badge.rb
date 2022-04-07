# frozen_string_literal: true

module DataTable
  module Formats
    # Formats value as a string
    class SafetyBadge
      def format(value)
        [value, style(value)]
      end

      def style(value)
        if value.blank?
          nil
        elsif value > 70
          'text-green-600'
        elsif value < 30
          'text-red-600'
        end
      end
    end
  end
end

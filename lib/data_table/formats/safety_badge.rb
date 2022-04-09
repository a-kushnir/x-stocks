# frozen_string_literal: true

module DataTable
  module Formats
    # Formats value as a string
    class SafetyBadge
      def format(value)
        [convert(value), style(value)]
      end

      def style(value)
        value = convert(value)
        if value.blank?
          nil
        elsif value > 70
          'text-green-600'
        elsif value < 30
          'text-red-600'
        end
      end

      private

      def convert(value)
        return value if value.blank?

        (value.round(1) * 20).to_i
      end
    end
  end
end

# frozen_string_literal: true

module DataTable
  module Formats
    # Formats value as a string
    class SafetyBadge
      def align
        :center
      end

      def format(value)
        convert(value)
      end

      def style(value)
        value = convert(value)
        if value.blank?
          nil
        elsif value > 70
          'positive'
        elsif value < 30
          'negative'
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

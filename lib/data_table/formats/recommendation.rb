# frozen_string_literal: true

require_relative 'number'

module DataTable
  module Formats
    # Formats value as a number
    class Recommendation < Number
      def format(value)
        return unless value.is_a?(Numeric)

        "<small>#{hint(value)}</small> #{number_with_precision(value, delimiter: ',', precision: 2)}".html_safe
      end

      def style(value)
        if value.blank?
          nil
        elsif value <= 2.5
          'positive'
        elsif value < 3.5
          'zero'
        elsif value < 4.5
          'negative'
        end
      end

      private

      def hint(value)
        if value <= 1.5
          'Str. Buy'
        elsif value <= 2.5
          'Buy'
        elsif value < 3.5
          'Hold'
        elsif value < 4.5
          'Sell'
        else
          'Str. Sell'
        end
      end
    end
  end
end

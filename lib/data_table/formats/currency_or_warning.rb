# frozen_string_literal: true

require_relative 'number'

module DataTable
  module Formats
    # Formats value as a US currency
    class CurrencyOrWarning < Number
      def format(value)
        value.is_a?(Numeric) ? number_to_currency(value) : value
      end

      def style(value)
        'warning' unless value.is_a?(Numeric)
      end
    end
  end
end

# frozen_string_literal: true

require_relative 'currency_or_warning'

module DataTable
  module Formats
    # Formats value as a US currency
    class CurrencyOrWarning4 < CurrencyOrWarning
      def format(value)
        return unless value.is_a?(Numeric)

        precision = 2
        precision = 3 if value.round(3) != value.round(2)
        precision = 4 if value.round(4) != value.round(3)
        number_to_currency(value, precision: precision)
      end
    end
  end
end

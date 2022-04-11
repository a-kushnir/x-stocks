# frozen_string_literal: true

require_relative 'number_delta'

module DataTable
  module Formats
    # Formats value as a US currency
    class CurrencyDelta < NumberDelta
      def format(value)
        number_to_currency(value)
      end
    end
  end
end

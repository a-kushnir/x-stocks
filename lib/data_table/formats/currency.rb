# frozen_string_literal: true

require_relative 'number'

module DataTable
  module Formats
    # Formats value as a US currency
    class Currency < Number
      def format(value)
        number_to_currency(value)
      end
    end
  end
end

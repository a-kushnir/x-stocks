# frozen_string_literal: true

require_relative 'currency'

module DataTable
  module Formats
    # Formats value as a US currency
    class BigCurrency < Currency
      def format(value)
        number_to_currency(number_to_human(value))
      end
    end
  end
end

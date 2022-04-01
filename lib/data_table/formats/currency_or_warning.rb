# frozen_string_literal: true

require 'action_view/helpers/number_helper'

module DataTable
  module Formats
    # Formats value as a US currency
    class CurrencyOrWarning
      include ActionView::Helpers::NumberHelper

      def format(value)
        if value.is_a?(Numeric)
          [number_to_currency(value), nil]
        else
          [value, 'text-red-600 font-bold']
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'action_view\helpers\number_helper'

module DataTable
  module Formats
    # Formats value as a US currency
    class CurrencyDelta
      include ActionView::Helpers::NumberHelper

      def format(value)
        [number_to_currency(value), style(value)]
      end

      def style(value)
        if value.to_f > 0
          'text-green-600'
        elsif value.to_f < 0
          'text-red-600'
        else
          'text-gray-600'
        end
      end
    end
  end
end

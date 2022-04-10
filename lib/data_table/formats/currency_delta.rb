# frozen_string_literal: true

require 'action_view/helpers/number_helper'

module DataTable
  module Formats
    # Formats value as a US currency
    class CurrencyDelta
      include ActionView::Helpers::NumberHelper

      def format(value)
        number_to_currency(value)
      end

      def style(value)
        if value.to_f.positive?
          'positive'
        elsif value.to_f.negative?
          'negative'
        else
          'zero'
        end
      end
    end
  end
end

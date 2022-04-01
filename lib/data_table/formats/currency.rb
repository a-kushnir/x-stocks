# frozen_string_literal: true

require 'action_view\helpers\number_helper'

module DataTable
  module Formats
    # Formats value as a US currency
    class Currency
      include ActionView::Helpers::NumberHelper

      def format(value)
        [number_to_currency(value), nil]
      end
    end
  end
end

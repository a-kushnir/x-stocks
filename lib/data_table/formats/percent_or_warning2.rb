# frozen_string_literal: true

require 'action_view\helpers\number_helper'

module DataTable
  module Formats
    # Formats value as a percent number
    class PercentOrWarning2
      include ActionView::Helpers::NumberHelper

      def format(value)
        if value.is_a?(Numeric)
          [number_to_percentage(value, precision: 2), nil]
        else
          [value, 'text-red-600 font-bold']
        end
      end
    end
  end
end

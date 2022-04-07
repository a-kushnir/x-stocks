# frozen_string_literal: true

require 'action_view/helpers/number_helper'

module DataTable
  module Formats
    # Formats value as a percent number
    class PercentDelta2
      include ActionView::Helpers::NumberHelper

      def format(value)
        [number_to_percentage(value, precision: 2), style(value)]
      end

      def style(value)
        if value.to_f.positive?
          'text-green-600'
        elsif value.to_f.negative?
          'text-red-600'
        else
          'text-gray-600'
        end
      end
    end
  end
end

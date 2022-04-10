# frozen_string_literal: true

require 'action_view/helpers/number_helper'

module DataTable
  module Formats
    # Formats value as a percent number
    class PercentDelta0
      include ActionView::Helpers::NumberHelper

      def format(value)
        return value if value.blank?

        result = number_to_percentage(value, precision: 0)
        value > 0 ? "+#{result}" : result
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

# frozen_string_literal: true

require 'action_view/helpers/number_helper'

module DataTable
  module Formats
    # Formats value as a number
    class Number
      include ActionView::Helpers::NumberHelper

      def align
        :right
      end

      def format(value)
        number_with_precision(value, delimiter: ',', strip_insignificant_zeros: true) if value.is_a?(Numeric)
      end

      def style(_value); end
    end
  end
end

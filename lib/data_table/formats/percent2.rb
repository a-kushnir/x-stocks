# frozen_string_literal: true

require 'action_view/helpers/number_helper'
require_relative 'number'

module DataTable
  module Formats
    # Formats value as a percent number
    class Percent2 < Number
      include ActionView::Helpers::NumberHelper

      def format(value)
        number_to_percentage(value, precision: 2)
      end

      def style(_value); end
    end
  end
end

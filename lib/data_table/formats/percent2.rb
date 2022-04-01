# frozen_string_literal: true

require 'action_view\helpers\number_helper'

module DataTable
  module Formats
    # Formats value as a percent number
    class Percent2
      include ActionView::Helpers::NumberHelper

      def format(value)
        [number_to_percentage(value, precision: 2), nil]
      end
    end
  end
end

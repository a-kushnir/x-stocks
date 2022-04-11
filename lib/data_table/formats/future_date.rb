# frozen_string_literal: true

require_relative 'date'

module DataTable
  module Formats
    # Formats value as a Date
    class FutureDate < Date
      def style(value)
        'zero' if value && !value.future?
      end
    end
  end
end

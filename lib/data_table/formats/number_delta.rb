# frozen_string_literal: true

require_relative 'number'

module DataTable
  module Formats
    # Formats value as a number
    class NumberDelta < Number
      def style(value)
        if value.to_f.positive?
          'text-positive'
        elsif value.to_f.negative?
          'text-negative'
        else
          'text-neutral'
        end
      end
    end
  end
end

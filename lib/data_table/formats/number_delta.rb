# frozen_string_literal: true

require_relative 'number'

module DataTable
  module Formats
    # Formats value as a number
    class NumberDelta < Number
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

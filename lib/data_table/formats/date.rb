# frozen_string_literal: true

module DataTable
  module Formats
    # Formats value as a Date
    class Date
      def align
        :right
      end

      def format(value)
        value&.strftime('%b, %d %Y')
      end

      def style(_value); end
    end
  end
end

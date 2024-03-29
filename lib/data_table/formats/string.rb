# frozen_string_literal: true

module DataTable
  module Formats
    # Formats value as a string
    class String
      def align
        :left
      end

      def format(value)
        value
      end

      def style(_value); end
    end
  end
end

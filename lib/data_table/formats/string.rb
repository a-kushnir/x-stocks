# frozen_string_literal: true

module DataTable
  module Formats
    # Formats value as a string
    class String
      def format(value)
        [value, nil]
      end
    end
  end
end

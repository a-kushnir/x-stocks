# frozen_string_literal: true

module XStocks
  module Dividends
    class DividendType
      REGULAR = 'regular' # Consistent Schedule Dividends
      SPECIAL = 'special' # Special Cash Dividends

      ALL = [
        REGULAR,
        SPECIAL
      ].freeze
    end
  end
end

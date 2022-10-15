# frozen_string_literal: true

module XStocks
  module Dividends
    class DividendType
      REGULAR = 'regular' # Consistent Schedule Dividends
      SPECIAL = 'special' # Special Cash Dividends
      LONG_TERM = 'long_term' # Long-Term capital gain distribution
      SHORT_TERM = 'short_term' # Short-Term capital gain distribution

      ALL = [
        REGULAR,
        SPECIAL,
        LONG_TERM,
        SHORT_TERM
      ].freeze
    end
  end
end

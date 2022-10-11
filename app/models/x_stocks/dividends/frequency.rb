# frozen_string_literal: true

module XStocks
  module Dividends
    class Frequency
      ONE_TIME = 0
      ANNUALLY = 1
      BI_ANNUALLY = 2
      QUARTERLY = 4
      MONTHLY = 12

      ALL = [
        ONE_TIME,
        ANNUALLY,
        BI_ANNUALLY,
        QUARTERLY,
        MONTHLY
      ].freeze
    end
  end
end

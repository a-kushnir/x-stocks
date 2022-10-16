# frozen_string_literal: true

module XStocks
  module Dividends
    # Dividend Frequency
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

      def self.code(value)
        {
          ONE_TIME => 'one_time',
          ANNUALLY => 'annually',
          BI_ANNUALLY => 'bi_annually',
          QUARTERLY => 'quarterly',
          MONTHLY => 'monthly'
        }[value]
      end

      def self.humanize(value)
        value = code(value)
        I18n.t("stocks.dividends.frequency.#{value}") if value
      end
    end
  end
end

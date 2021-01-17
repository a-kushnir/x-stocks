# frozen_string_literal: true

module Etl
  module Transform
    # Transforms data extracted from finance.yahoo.com
    class Yahoo
      RECOMMENDATIONS = %w[strongBuy buy hold sell strongSell].freeze

      def initialize(date: Date)
        @date = date
      end

      def summary(stock, json)
        summary = json&.dig('context', 'dispatcher', 'stores')

        stock.outstanding_shares = summary&.dig('StreamDataStore', 'quoteData', stock.symbol, 'sharesOutstanding', 'raw')
        stock.payout_ratio = to_pct(summary&.dig('QuoteSummaryStore', 'summaryDetail', 'payoutRatio', 'raw'))
        stock.yahoo_beta = summary&.dig('QuoteSummaryStore', 'defaultKeyStatistics', 'beta', 'raw')
        stock.yahoo_rec = summary&.dig('QuoteSummaryStore', 'financialData', 'recommendationMean', 'raw')
        stock.yahoo_rec_details = to_rec(summary&.dig('QuoteSummaryStore', 'recommendationTrend', 'trend'))
        stock.est_annual_dividend = summary&.dig('QuoteSummaryStore', 'summaryDetail', 'dividendRate', 'raw')
        stock.yahoo_discount = summary&.dig('ResearchPageStore', 'technicalInsights', stock.symbol, 'instrumentInfo', 'valuation', 'discount')

        description = summary&.dig('QuoteSummaryStore', 'summaryProfile', 'longBusinessSummary')
        stock.description = description if description.present?

        stock.update_dividends!
      end

      private

      def to_pct(value)
        value ? value.to_f * 100 : nil
      end

      def to_rec(data)
        return nil if data.blank?

        result = {}
        month = date.today.at_beginning_of_month - 3.months
        data.reverse_each do |stat|
          result[month.to_s] = RECOMMENDATIONS.map { |key| stat[key] }
          month += 1.month
        end

        result
      end

      attr_reader :date
    end
  end
end

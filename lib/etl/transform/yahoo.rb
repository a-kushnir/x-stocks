# frozen_string_literal: true

module Etl
  module Transform
    # Transforms data extracted from finance.yahoo.com
    class Yahoo
      RECOMMENDATIONS = %w[strongBuy buy hold sell strongSell].freeze

      def summary(stock, json)
        summary = json&.dig('context', 'dispatcher', 'stores')

        stock.outstanding_shares = summary&.dig('StreamDataStore', 'quoteData', stock.symbol, 'sharesOutstanding', 'raw')
        stock.payout_ratio = begin
                               summary&.dig('QuoteSummaryStore', 'summaryDetail', 'payoutRatio', 'raw') * 100
                             rescue StandardError
                               nil
                             end
        stock.yahoo_beta = summary&.dig('QuoteSummaryStore', 'defaultKeyStatistics', 'beta', 'raw')
        stock.yahoo_rec = summary&.dig('QuoteSummaryStore', 'financialData', 'recommendationMean', 'raw')
        stock.yahoo_rec_details = to_rec(summary&.dig('QuoteSummaryStore', 'recommendationTrend', 'trend'))
        stock.est_annual_dividend = summary&.dig('QuoteSummaryStore', 'summaryDetail', 'dividendRate', 'raw')
        stock.yahoo_discount = begin
                                 summary&.dig('ResearchPageStore', 'technicalInsights', stock.symbol, 'instrumentInfo', 'valuation', 'discount')
                               rescue StandardError
                                 nil
                               end

        description = summary&.dig('QuoteSummaryStore', 'summaryProfile', 'longBusinessSummary')
        stock.description = description if description.present?

        stock.update_dividends!
      end

      private

      def to_rec(data)
        return nil if data.blank?

        result = {}
        month = Date.today.at_beginning_of_month - 3.months
        data.reverse_each do |stat|
          result[month.to_s] = RECOMMENDATIONS.map { |key| stat[key] }
          month += 1.month
        end

        result
      end
    end
  end
end

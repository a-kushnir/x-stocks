# frozen_string_literal: true

module Etl
  module Transform
    # Transforms data extracted from finance.yahoo.com
    class Yahoo
      RECOMMENDATIONS = %w[strongBuy buy hold sell strongSell].freeze

      def initialize(date: Date, stock_model: XStocks::Stock)
        @date = date
        @stock_model = stock_model
      end

      def summary(stock, json)
        summary = json&.dig('context', 'dispatcher', 'stores')

        set(stock, :outstanding_shares, summary&.dig('StreamDataStore', 'quoteData', stock.symbol, 'sharesOutstanding', 'raw'))
        set(stock, :payout_ratio, to_pct(summary&.dig('QuoteSummaryStore', 'summaryDetail', 'payoutRatio', 'raw')))
        set(stock, :yahoo_beta, summary&.dig('QuoteSummaryStore', 'defaultKeyStatistics', 'beta', 'raw'))
        set(stock, :yahoo_rec, summary&.dig('QuoteSummaryStore', 'financialData', 'recommendationMean', 'raw'))
        set(stock, :yahoo_rec_details, to_rec(summary&.dig('QuoteSummaryStore', 'recommendationTrend', 'trend')))
        set(stock, :est_annual_dividend, summary&.dig('QuoteSummaryStore', 'summaryDetail', 'dividendRate', 'raw'))
        set(stock, :yahoo_discount, summary&.dig('ResearchPageStore', 'technicalInsights', stock.symbol, 'instrumentInfo', 'valuation', 'discount'))
        set(stock, :description, summary&.dig('QuoteSummaryStore', 'summaryProfile', 'longBusinessSummary'))

        stock_model.new.save(stock)
      end

      private

      def set(stock, attribute, value)
        stock[attribute] = value if value
      end

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

      attr_reader :date, :stock_model
    end
  end
end

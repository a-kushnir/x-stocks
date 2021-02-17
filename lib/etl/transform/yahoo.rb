# frozen_string_literal: true

module Etl
  module Transform
    # Transforms data extracted from finance.yahoo.com
    class Yahoo
      RECOMMENDATIONS = %w[strongBuy buy hold sell strongSell].freeze
      QUARTER_WITH_YEAR_REGEX = /(\d)Q(\d{4})/.freeze
      QUARTER_REGEX = /(\d)/.freeze

      def initialize(date: Date, stock_model: XStocks::Stock)
        @date = date
        @stock_model = stock_model
      end

      def summary(stock, json)
        summary = json&.dig('context', 'dispatcher', 'stores')
        stream_data_store = summary&.dig('StreamDataStore')
        quote_summary_store = summary&.dig('QuoteSummaryStore')
        research_page_store = summary&.dig('ResearchPageStore')

        set(stock, :outstanding_shares, stream_data_store&.dig('quoteData', stock.symbol, 'sharesOutstanding', 'raw'))
        set(stock, :payout_ratio, to_pct(quote_summary_store&.dig('summaryDetail', 'payoutRatio', 'raw')))
        set(stock, :yahoo_beta, quote_summary_store&.dig('defaultKeyStatistics', 'beta', 'raw'))
        set(stock, :yahoo_rec, quote_summary_store&.dig('financialData', 'recommendationMean', 'raw'))
        set(stock, :yahoo_rec_details, to_rec(quote_summary_store&.dig('recommendationTrend', 'trend')))
        set(stock, :est_annual_dividend, quote_summary_store&.dig('summaryDetail', 'dividendRate', 'raw'))
        set(stock, :yahoo_discount, research_page_store&.dig('technicalInsights', stock.symbol, 'instrumentInfo', 'valuation', 'discount'))
        set(stock, :description, quote_summary_store&.dig('summaryProfile', 'longBusinessSummary'))
        set(stock, :yahoo_price_target, price_target(quote_summary_store&.dig('financialData')))
        set(stock, :earnings, earnings(quote_summary_store&.dig('earnings', 'earningsChart')))
        set(stock, :financials_yearly, financials_yearly(quote_summary_store&.dig('earnings', 'financialsChart')))
        set(stock, :financials_quarterly, financials_quarterly(quote_summary_store&.dig('earnings', 'financialsChart')))

        stock_model.new.save(stock)
      end

      private

      def price_target(financial_data)
        return unless financial_data

        {
          high: financial_data.dig('targetHighPrice', 'raw'),
          low: financial_data.dig('targetLowPrice', 'raw'),
          mean: financial_data.dig('targetMeanPrice', 'raw'),
          median: financial_data.dig('targetMedianPrice', 'raw')
        }.compact
      end

      def earnings(earnings_chart)
        return unless earnings_chart

        quarterly = earnings_chart['quarterly']
        return unless quarterly

        result = []
        quarterly.each do |data|
          next if data['date'].blank?

          match = data['date'].match(QUARTER_WITH_YEAR_REGEX)
          quarter, year = match.captures
          next if quarter.blank? || year.blank?

          earnings = {
            eps_estimate: data.dig('estimate', 'raw'),
            eps_actual: data.dig('actual', 'raw'),
            quarter: quarter.to_i,
            year: year.to_i
          }

          result << earnings if earnings[:eps_actual] && earnings[:quarter] && earnings[:year]
        end

        est_date = earnings_chart['currentQuarterEstimateDate']
        if est_date
          quarter = est_date.match(QUARTER_REGEX).captures[0]
          earnings = {
            eps_estimate: earnings_chart.dig('currentQuarterEstimate', 'raw'),
            eps_actual: nil,
            quarter: quarter.to_i,
            year: earnings_chart['currentQuarterEstimateYear']
          }
          result << earnings if earnings[:eps_estimate] && earnings[:quarter] && earnings[:year]
        end

        result.presence
      end

      def financials_yearly(financials_chart)
        return unless financials_chart.present?

        yearly = financials_chart['yearly']
        return unless yearly.present?

        yearly.map do |data|
          next if data.dig('revenue', 'raw').blank?
          next if data.dig('earnings', 'raw').blank?
          next if data['date'].blank?

          {
            revenue: data.dig('revenue', 'raw'),
            earnings: data.dig('earnings', 'raw'),
            year: data['date']
          }
        end.compact.presence
      end

      def financials_quarterly(financials_chart)
        return unless financials_chart.present?

        quarterly = financials_chart['quarterly']
        return unless quarterly.present?

        quarterly.map do |data|
          match = data['date'].match(QUARTER_WITH_YEAR_REGEX)
          quarter, year = match.captures

          next if data.dig('revenue', 'raw').blank?
          next if data.dig('earnings', 'raw').blank?
          next if quarter.blank?
          next if year.blank?

          {
            revenue: data.dig('revenue', 'raw'),
            earnings: data.dig('earnings', 'raw'),
            quarter: quarter.to_i,
            year: year.to_i
          }
        end.compact.presence
      end

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

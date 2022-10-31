# frozen_string_literal: true

module Etl
  module Transform
    # Transforms data extracted from polygon.io
    class Polygon
      DIVIDENDS_UNIQUE_KEY = %i[stock_id dividend_type ex_dividend_date amount].freeze
      FINANCIALS_UNIQUE_KEY = %i[cik fiscal_year fiscal_period]

      def initialize(stock)
        @stock = stock
      end

      def dividends(json)
        return if json&.dig('status') != 'OK'

        rows = json['results'].map do |row|
          next if row.values_at('declaration_date', 'ex_dividend_date', 'record_date', 'pay_date', 'cash_amount').any?(&:blank?)

          {
            stock_id: stock.id,
            declaration_date: date(row['declaration_date']),
            ex_dividend_date: date(row['ex_dividend_date']),
            record_date: date(row['record_date']),
            pay_date: date(row['pay_date']),
            dividend_type: dividend_type(row['dividend_type']),
            currency: row['currency'],
            amount: amount(row['cash_amount']),
            frequency: row['frequency'].to_i
          }
        end.compact

        new_rows, existing_rows = filter_dividends(rows)
        new_rows.map! { |attributes| XStocks::AR::Dividend.new(attributes) }

        [new_rows, existing_rows]
      end

      def financials(json)
        return if json&.dig('status') != 'OK'

        fields = {
          common_stock_shares_outstanding: ->(html) { html.scan(%r{<dei:EntityCommonStockSharesOutstanding[^>]+>([^>]+)<\/dei:EntityCommonStockSharesOutstanding>})&.dig(0, 0)&.to_i },
        }.freeze

        rows = json['results'].map do |row|
          next if row.values_at(*%w(cik start_date end_date fiscal_year fiscal_period)).any?(&:blank?)

          xml = yield row

          row.slice(*%w(cik start_date end_date fiscal_year fiscal_period common_stock_shares_outstanding))
            .merge(fields.to_h { |key,proc| [key.to_s, proc.call(xml)] })
            .merge(stock_id: stock.id)
        end.compact

        new_rows, existing_rows = filter_financials(rows)
        new_rows.map! { |attributes| XStocks::AR::Financial.new(attributes) }

        [new_rows, existing_rows]
      end

      def filter_dividends(rows)
        rows.partition { |row| !existing_dividends.include?(row.values_at(*DIVIDENDS_UNIQUE_KEY)) }
      end

      def existing_dividends
        @existing_dividends ||= XStocks::AR::Dividend.where(stock_id: stock.id).pluck(*DIVIDENDS_UNIQUE_KEY)
      end

      def filter_financials(rows)
        rows.partition { |row| !existing_financials.include?(row.values_at(*FINANCIALS_UNIQUE_KEY)) }
      end

      def existing_financials
        @existing_financials ||= XStocks::AR::Financial.where(stock_id: stock.id).pluck(*FINANCIALS_UNIQUE_KEY)
      end

      def date(value)
        Date.parse(value)
      end

      def dividend_type(value)
        {
          'CD' => XStocks::Dividends::DividendType::REGULAR,
          'SC' => XStocks::Dividends::DividendType::SPECIAL,
          'LT' => XStocks::Dividends::DividendType::LONG_TERM,
          'ST' => XStocks::Dividends::DividendType::SHORT_TERM
        }.fetch(value)
      end

      def amount(value)
        value.to_f.round(4)
      end

      attr_reader :stock
    end
  end
end

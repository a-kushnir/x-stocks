# frozen_string_literal: true

module Etl
  module Transform
    # Transforms data extracted from polygon.io
    class Polygon
      UNIQUE_KEY = %i[stock_id pay_date amount].freeze

      def dividends(stock, json)
        return if json&.dig('status') != 'OK'

        rows = json['results'].map do |row|
          {
            stock_id: stock.id,
            declaration_date: date(row['declaration_date']),
            ex_dividend_date: date(row['ex_dividend_date']),
            record_date: date(row['record_date']),
            pay_date: date(row['pay_date']),
            dividend_type: dividend_type(row['dividend_type']),
            amount: amount(row['cash_amount']),
            frequency: row['frequency']
          }
        end

        rows = filter_existing(stock, rows)
        rows.map { |attributes| XStocks::AR::Dividend.create(attributes) }.any?
        # TODO: Update Stock
      end

      def filter_existing(stock, rows)
        existing_rows = XStocks::AR::Dividend.where(stock_id: stock.id).pluck(*UNIQUE_KEY)
        rows.reject { |row| existing_rows.include?(row.values_at(*UNIQUE_KEY)) }
      end

      def date(value)
        Date.parse(value)
      end

      def dividend_type(value)
        {
          'CD' => XStocks::Dividends::DividendType::REGULAR,
          'SC' => XStocks::Dividends::DividendType::SPECIAL
        }.fetch(value)
      end

      def amount(value)
        value.to_f.round(4)
      end
    end
  end
end

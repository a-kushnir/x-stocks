# frozen_string_literal: true

module Etl
  module Transform
    # Transforms data extracted from polygon.io
    class Polygon
      UNIQUE_KEY = %i[stock_id pay_date amount].freeze

      def initialize(stock)
        @stock = stock
      end

      def dividends(json)
        return if json&.dig('status') != 'OK'

        rows = json['results'].map do |row|
          next unless row['pay_date']

          {
            stock_id: stock.id,
            declaration_date: date(row['declaration_date']),
            ex_dividend_date: date(row['ex_dividend_date']),
            record_date: date(row['record_date']),
            pay_date: date(row['pay_date']),
            dividend_type: dividend_type(row['dividend_type']),
            currency: row['currency'],
            amount: amount(row['cash_amount']),
            frequency: row['frequency']
          }
        end.compact

        new_rows, existing_rows = filter(rows)
        new_rows.map! { |attributes| XStocks::AR::Dividend.new(attributes) }

        [new_rows, existing_rows]
      end

      def filter(rows)
        rows.partition { |row| !existing_rows.include?(row.values_at(*UNIQUE_KEY)) }
      end

      def existing_rows
        @existing_rows ||= XStocks::AR::Dividend.where(stock_id: stock.id).pluck(*UNIQUE_KEY)
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

      attr_reader :stock
    end
  end
end

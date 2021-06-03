# frozen_string_literal: true

module Etl
  module Transform
    # Transforms data extracted from polygon.io
    class Polygon
      def initialize(stock_ar_class: XStocks::AR::Stock,
                     dividend_frequencies: XStocks::Stock::Dividends::DIVIDEND_FREQUENCIES)
        @stock_ar_class = stock_ar_class
        @dividend_frequencies = dividend_frequencies
      end

      def dividends(stock, json)
        return if json&.dig('status') != 'OK'

        details = json.dig('results').map do |row|
          {
            'ex_date' => row['exDate'],
            'payment_date' => row['paymentDate'],
            'record_date' => row['recordDate'],
            'declared_date' => row['declaredDate'],
            'amount' => row['amount'].to_d
          }
        end
        detect_div_frequency(details)

        stock.dividend_details ||= []
        stock.dividend_details += details
        stock.dividend_details.uniq! { |row| row['payment_date'] }
        stock.dividend_details.sort_by! { |row| row['payment_date'] }
        stock.dividend_details.reject! { |row| row['amount'].blank? || row['amount'].to_f.zero? }
        stock.dividend_details.each { |row| row['amount'] = row['amount'].to_f }

        last_div = stock.periodic_dividend_details.last
        stock.dividend_frequency = last_div&.dig('frequency')
        stock.dividend_frequency_num = dividend_frequencies[(stock.dividend_frequency || '').downcase]
        stock.dividend_amount = last_div&.dig('amount')
        stock.est_annual_dividend = (stock.dividend_frequency_num * stock.dividend_amount if stock.dividend_frequency_num && stock.dividend_amount)

        # TODO Calc Next Div

        stock.save
      end

      private

      def detect_div_frequency(details)
        dates = details.map { |detail| detail['ex_date'] }
        periods = dates.each_cons(2).map { |a,b| (Date.parse(a) - Date.parse(b)).to_i }

        frequencies = periods.map do |period|
          dividend_frequencies.detect do |_name, freq|
            range(365 / freq, 7).include?(period)
          end&.first
        end

        frequency = frequencies.compact.group_by { |freq| freq }.max_by {|_, freq| freq.size }&.first

        frequencies.each_with_index do |freq, index|
          if freq == frequency
            details[index]['frequency'] = freq
            details[index + 1]['frequency'] = freq
          end
        end

        details.each do |detail|
          detail['frequency'] ||= 'unspecified'
        end

        details
      end

      def range(base, delta)
        (base-delta)..(base+delta)
      end

      attr_reader :stock_ar_class, :dividend_frequencies
    end
  end
end

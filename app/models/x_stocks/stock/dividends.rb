# frozen_string_literal: true

module XStocks
  class Stock
    # Stock Dividends Business Model
    module Dividends
      DAYS_IN_YEAR = 365.25
      DIVIDEND_FREQUENCIES = {
        'annual' => 1,
        'semi-annual' => 2,
        'quarterly' => 4,
        'monthly' => 12
      }.freeze

      def div_suspended?(stock)
        (stock.dividend_amount || stock.est_annual_dividend || stock.dividend_frequency_num || stock.dividend_growth_3y || stock.dividend_growth_5y) &&
          (stock.next_div_ex_date.nil? || next_div_ex_date_overdue?(stock)) && last_dividend_details_overdue?(stock)
      end

      def next_div_ex_date_overdue?(stock)
        stock.next_div_ex_date.past? && (stock.next_div_ex_date < (1.5 * DAYS_IN_YEAR / stock.dividend_frequency_num).days.ago)
      rescue StandardError
        true
      end

      def last_dividend_details_overdue?(stock)
        last_div = stock.dividend_details&.last
        last_div.nil? || (last_div['ex_date'] < (1.5 * DAYS_IN_YEAR / stock.dividend_frequency_num).days.ago)
      rescue StandardError
        true
      end

      def div_change_pct(stock)
        if div_suspended?(stock)
          -100
        else
          details = periodic_dividend_details(stock)
          size = details.size
          last = details[size - 1]
          prev = details[size - 2]
          if last && prev
            begin
              100 * ((last['amount'] - prev['amount']) / prev['amount']).round(4)
            rescue StandardError
              0
            end
          end
        end
      end

      def periodic_dividend_details(stock)
        (stock.dividend_details || []).select { |detail| DIVIDEND_FREQUENCIES[(detail['frequency'] || '').downcase] }
      end
    end
  end
end

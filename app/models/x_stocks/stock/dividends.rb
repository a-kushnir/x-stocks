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

      def div_suspended?
        (ar_stock.dividend_amount || ar_stock.est_annual_dividend || ar_stock.dividend_frequency_num || ar_stock.dividend_growth_3y || ar_stock.dividend_growth_5y) &&
          (ar_stock.next_div_ex_date.nil? || next_div_ex_date_overdue?) && last_dividend_details_overdue?
      end

      def next_div_ex_date_overdue?
        ar_stock.next_div_ex_date.past? && (ar_stock.next_div_ex_date < (1.5 * DAYS_IN_YEAR / ar_stock.dividend_frequency_num).days.ago)
      rescue StandardError
        true
      end

      def last_dividend_details_overdue?
        last_div = ar_stock.dividend_details&.last
        last_div.nil? || (last_div['ex_date'] < (1.5 * DAYS_IN_YEAR / ar_stock.dividend_frequency_num).days.ago)
      rescue StandardError
        true
      end

      def div_change_pct
        if div_suspended?
          -100
        else
          details = periodic_dividend_details
          size = details.size
          last = details[size - 1]
          prev = details[size - 2]
          if last && prev
            begin
              100 * ((last['amount'] - prev['amount']) / prev['amount']).round(4)
            rescue StandardError
              nil
            end
          end
        end
      end

      def periodic_dividend_details
        (ar_stock.dividend_details || []).select { |detail| DIVIDEND_FREQUENCIES[(detail['frequency'] || '').downcase] }
      end
    end
  end
end

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

      def self.future_ex_date
        # Pre-Market Hours: 9 AM to 9:30 AM EST
        # Regular Market Hours: 9:30 AM to 4 PM EST
        # After Hours: 4 PM to 6 PM EST
        time = Time.now.in_time_zone('EST')
        time.hour < 16 ? time.to_date : time.to_date + 1
      end

      def self.prev_month_ex_date
        future_ex_date - 1.month
      end

      def self.next_month_ex_date
        future_ex_date + 1.month
      end

      def next_month_ex_date?
        ar_stock.next_div_ex_date &&
          ar_stock.next_div_ex_date >= Dividends.future_ex_date &&
          ar_stock.next_div_ex_date < Dividends.next_month_ex_date
      end

      def prev_month_ex_date?
        ar_stock.next_div_ex_date &&
          ar_stock.next_div_ex_date > Dividends.prev_month_ex_date
      end

      def div_suspended?
        (ar_stock.dividend_amount || ar_stock.est_annual_dividend || ar_stock.dividend_frequency_num || ar_stock.dividend_growth_3y || ar_stock.dividend_growth_5y) &&
          (ar_stock.next_div_ex_date.nil? || next_div_ex_date_overdue?) && last_dividend_overdue?
      end

      def next_div_ex_date_overdue?
        ar_stock.next_div_ex_date.past? && (ar_stock.next_div_ex_date < (1.5 * DAYS_IN_YEAR / ar_stock.dividend_frequency_num).days.ago)
      rescue StandardError
        true
      end

      def last_dividend_overdue?
        last_div = ar_stock.dividends.regular.first
        last_div.nil? || (last_div.ex_dividend_date < (1.5 * DAYS_IN_YEAR / last_div.frequency).days.ago)
      rescue StandardError
        true
      end

      def prev_div_amount
        _, prev = dividends.regular.first(2)
        prev&.amount || 0
      end

      def next_div_amount2
        return 0 if div_suspended?

        last, = dividends.regular.first(2)
        last&.amount || 0
      end

      def div_change_pct
        return -100 if div_suspended?

        last, prev = ar_stock.dividends.regular.first(2)
        return 100 unless prev

        100 * ((last.amount - prev.amount) / prev.amount).round(4) if last && prev
      end
    end
  end
end

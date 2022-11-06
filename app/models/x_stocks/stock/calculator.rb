# frozen_string_literal: true

module XStocks
  class Stock
    # Stock Calculator Business Model
    module Calculator
      def calculate_stock_prices
        ar_stock.day_high_price = [ar_stock.current_price, ar_stock.day_high_price].compact.max if ar_stock.day_high_price
        ar_stock.day_low_price = [ar_stock.current_price, ar_stock.day_low_price].compact.min if ar_stock.day_low_price
        ar_stock.week_52_high = [ar_stock.current_price, ar_stock.day_high_price, ar_stock.week_52_high].compact.max if ar_stock.week_52_high
        ar_stock.week_52_low = [ar_stock.current_price, ar_stock.day_low_price, ar_stock.week_52_low].compact.min if ar_stock.week_52_low
        ar_stock.price_change = safe_exec { ar_stock.current_price - ar_stock.prev_close_price }
        ar_stock.price_change_pct = safe_exec { ar_stock.price_change / ar_stock.prev_close_price * 100 }
        ar_stock.market_capitalization = safe_exec { ar_stock.outstanding_shares * ar_stock.current_price }
        ar_stock.pe_ratio_ttm = safe_exec { ar_stock.current_price / ar_stock.eps_ttm }
        ar_stock.yahoo_discount = safe_exec { ((ar_stock.yahoo_fair_price / ar_stock.current_price) - 1) * 100 }
      end

      def calculate_stock_dividends
        regular_div = ar_stock.dividends.regular.first
        next_div = ar_stock.dividends.future_ex_dividend_date.last

        ar_stock.dividend_frequency_num = regular_div&.frequency
        ar_stock.next_div_ex_date = next_div&.ex_dividend_date
        ar_stock.next_div_payment_date = next_div&.pay_date
        ar_stock.next_div_amount = next_div&.amount

        amount = (DividendCalculator.est_amount(ar_stock) if ar_stock.dividend_frequency_num)
        ar_stock.est_annual_dividend = (ar_stock.dividend_frequency_num * amount if ar_stock.dividend_frequency_num && amount)
        ar_stock.est_annual_dividend_pct = (ar_stock.est_annual_dividend / ar_stock.current_price * 100 if ar_stock.est_annual_dividend && ar_stock.current_price)
      end

      private

      def safe_exec
        yield
      rescue StandardError
        nil
      end
    end
  end
end

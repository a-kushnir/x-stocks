# frozen_string_literal: true

module XStocks
  class Stock
    # Stock Calculator Business Model
    module Calculator
      def calculate_stock_prices
        ar_stock.week_52_high = [ar_stock.current_price, ar_stock.week_52_high].compact.max if ar_stock.week_52_high
        ar_stock.week_52_low = [ar_stock.current_price, ar_stock.week_52_low].compact.min if ar_stock.week_52_low
        ar_stock.price_change = safe_exec { ar_stock.current_price - ar_stock.prev_close_price }
        ar_stock.price_change_pct = safe_exec { ar_stock.price_change / ar_stock.prev_close_price * 100 }
        ar_stock.market_capitalization = safe_exec { ar_stock.outstanding_shares * ar_stock.current_price }
        ar_stock.pe_ratio_ttm = safe_exec { ar_stock.current_price / ar_stock.eps_ttm }
        ar_stock.yahoo_discount = safe_exec { (ar_stock.yahoo_fair_price / ar_stock.current_price - 1) * 100 }

        calculate_stock_dividends
      end

      def calculate_stock_dividends
        ar_stock.est_annual_dividend_pct = safe_exec { ar_stock.est_annual_dividend / ar_stock.current_price * 100 }
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

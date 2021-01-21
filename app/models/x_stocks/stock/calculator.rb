# frozen_string_literal: true

module XStocks
  class Stock
    # Stock Calculator Business Model
    module Calculator
      def calculate_stock_prices(stock)
        stock.price_change = safe_exec { stock.current_price - stock.prev_close_price }
        stock.price_change_pct = safe_exec { stock.price_change / stock.prev_close_price * 100 }
        stock.market_capitalization = safe_exec { stock.outstanding_shares * stock.current_price }
        calculate_stock_dividends(stock)
      end

      def calculate_stock_dividends(stock)
        stock.est_annual_dividend_pct = safe_exec { stock.est_annual_dividend / stock.current_price * 100 }
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

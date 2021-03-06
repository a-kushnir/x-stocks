# frozen_string_literal: true

module XStocks
  class Position
    # Position Calculator Business Model
    module Calculator
      def calculate_stock_prices(stock)
        relation = position_ar_class.where(stock: stock)
        relation.update_all(market_price: stock.current_price)
        relation.update_all('market_value = market_price * shares')
        relation.update_all('gain_loss = market_value - total_cost')
        relation.update_all('gain_loss_pct = gain_loss / total_cost * 100')
      end

      def div_suspended?(stock)
        XStocks::Stock.new(stock).div_suspended?
      end

      def calculate_stock_dividends(stock)
        relation = position_ar_class.where(stock: stock)
        relation.update_all(est_annual_dividend: div_suspended?(stock) ? nil : stock.est_annual_dividend)
        relation.update_all('est_annual_income = est_annual_dividend * shares')
      end

      def update_timestamp(stock)
        relation = position_ar_class.where(stock: stock)
        relation.update_all(updated_at: stock.updated_at)
      end

      def calculate_position_prices(position)
        position.total_cost = safe_exec { position.average_price * position.shares }
        position.market_price = position.stock.current_price
        position.market_value = safe_exec { position.market_price * position.shares }
        position.gain_loss = safe_exec { position.market_value - position.total_cost }
        position.gain_loss_pct = safe_exec { position.gain_loss / position.total_cost * 100 }
        position.stop_loss_value = safe_exec { position.stop_loss * position.shares }
        position.stop_loss_gain_loss = safe_exec { position.stop_loss_value - position.total_cost }
        position.stop_loss_gain_loss_pct = safe_exec { position.stop_loss_gain_loss / position.total_cost * 100 }
      end

      def calculate_position_dividends(position)
        position.est_annual_dividend = div_suspended?(position.stock) ? nil : position.stock.est_annual_dividend
        position.est_annual_income = safe_exec { position.est_annual_dividend * position.shares }
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

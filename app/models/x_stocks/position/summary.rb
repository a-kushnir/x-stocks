# frozen_string_literal: true

module XStocks
  class Position
    # Position Summary Business Model
    module Summary
      def day_change(user)
        summary =
          position_ar_class
          .select('SUM(positions.market_value) market_value, SUM(positions.shares * stocks.price_change) price_change')
          .joins('JOIN stocks ON positions.stock_id = stocks.id')
          .where(user: user)
          .to_a
          .first

        {
          market_value: summary.market_value || 0,
          price_change: summary.price_change || 0,
          price_change_pct: safe_exec { summary.price_change / summary.market_value * 100 }
        }
      end

      def market_value(user)
        position_ar_class
          .where(user: user)
          .sum(:market_value)
      end

      def est_ann_income(user)
        position_ar_class
          .where(user: user)
          .sum(:est_annual_income)
      end
    end
  end
end

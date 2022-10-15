# frozen_string_literal: true

module XStocks
  module Notifications
    # Dividend Change Notification
    class DividendChange
      def initialize(user, stock, position)
        @user = user
        @stock = XStocks::Stock.new(stock)
        @position = position
      end

      def subject
        div_change_pct = @stock.div_change_pct
        return "Dividend Cut (#{@stock.symbol})" if div_change_pct.negative?
        return "Dividend Hike (#{@stock.symbol})" if div_change_pct.positive?

        "Declared Dividend (#{@stock.symbol})"
      end

      def position?
        position&.shares
      end

      def est_annual_income_was
        next_div_amount = stock.next_div_amount2
        prev_div_amount = stock.prev_div_amount
        est_annual_income / next_div_amount * prev_div_amount
      end

      def div_suspended?
        # rubocop:disable Style/IfWithBooleanLiteralBranches
        @div_suspended = (@stock.div_suspended? ? true : false) if @div_suspended.nil?
        # rubocop:enable Style/IfWithBooleanLiteralBranches
        @div_suspended
      end

      def est_annual_dividend_taxed
        @est_annual_dividend_taxed ||= stock.est_annual_dividend_taxed(user)
      end

      def est_annual_dividend_taxed_pct
        @est_annual_dividend_taxed_pct ||= stock.est_annual_dividend_taxed_pct(user)
      end

      def div_change_pct
        @div_change_pct ||= stock.div_change_pct
      end

      def next_div_amount
        @next_div_amount ||= stock.next_div_amount2
      end

      delegate :symbol, :company_name, :exchange, :current_price, :price_change, :price_change_pct,
               :dividends, :dividend_growth_3y, :dividend_growth_5y, :dividend_growth_years, :dividend_rating,
               :payout_ratio, :est_annual_dividend, :est_annual_dividend_pct, :prev_div_amount, to: :stock
      delegate :est_annual_income, :shares, to: :position
      attr_reader :user, :position, :stock
    end
  end
end

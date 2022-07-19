# frozen_string_literal: true

module Dividends
  # Chart representation of user portfolio dividends
  class ChartController < ApplicationController
    helper :stocks

    def index
      @positions = XStocks::AR::Position
                   .where(user: current_user)
                   .where.not(shares: nil)
                   .all
      return unless stale?(@positions)

      @positions = @positions.to_a
      @data, @summary = data(@positions)

      @page_title = t('dividends.pages.dividends')
      @page_menu_item = :dividends
    end

    private

    def safety(value)
      return value if value.blank?

      (value.round(1) * 20).to_i
    end

    def data(positions)
      dividend = ::Dividend.new
      months = dividend.months

      stocks = XStocks::Stock.find_all(id: positions.map(&:stock_id))
      @stocks_by_id = stocks.index_by(&:id)

      total_market_value = positions.sum(&:market_value)
      month_amounts = months.map { 0 }
      avg_dividend_rating = XStocks::Position::AvgDividendRating.new

      data = []
      positions.each do |position|
        stock = @stocks_by_id[position.stock_id]
        div_suspended = stock.div_suspended?
        estimates = dividend.estimate(stock)
        avg_dividend_rating.add(stock.dividend_rating, div_suspended, position.market_value)

        months.each_with_index do |month, index|
          amount = month_dividends(estimates, div_suspended, position, month)
          month_amounts[index] += amount if amount
        end

        data << row(stock, position, months, estimates, div_suspended, total_market_value)
      end

      summary = {
        month_amounts: month_amounts,
        total_amount: month_amounts.sum,
        dividend_rating: avg_dividend_rating.value
      }

      [data, summary(positions, summary)]
    end

    def row(stock, position, months, estimates, div_suspended, total_market_value)
      diversity = position.market_value && total_market_value ? (position.market_value / total_market_value * 100).round(2) : nil
      flag = CountryFlag.new

      result =
        [
          # Stock
          view_context.link_to(stock.symbol, stock_url(stock.symbol), class: 'text-blue-500 no-underline inline-block w-full'),
          stock.company_name,
          flag.code(stock.country),
          value_or_warning(div_suspended, stock.est_annual_dividend_pct&.to_f),
          stock.div_change_pct&.round(1),
          safety(stock.dividend_rating&.to_f),
          # Position
          position.total_cost&.to_f,
          position.market_value&.to_f,
          position.gain_loss&.to_f,
          position.gain_loss_pct&.to_f,
          diversity&.to_f
        ]
      # Dividends
      months.each { |month| result << month_dividends(estimates, div_suspended, position, month) }
      result << value_or_warning(div_suspended, annual_dividends(estimates, div_suspended, position))
    end

    def month_dividends(estimates, div_suspended, position, month)
      return nil if div_suspended

      amount = estimates&.detect { |e| e[:month] == month }&.dig(:amount)
      (amount * position.shares).round(2).to_f if amount
    end

    def annual_dividends(estimates, div_suspended, position)
      return nil if div_suspended

      amount = estimates&.map { |estimate| estimate[:amount] }&.sum
      (amount * position.shares).round(2).to_f if amount
    end

    def value_or_warning(div_suspended, value)
      div_suspended ? 'Sus.' : value
    end

    def summary(positions, summary)
      total_cost = positions.map(&:total_cost).compact.sum || 0
      market_value = positions.map(&:market_value).compact.sum || 0
      gain_loss = market_value - total_cost
      gain_loss_pct = total_cost.positive? ? gain_loss / total_cost * 100 : 0
      est_annual_income = positions.map(&:est_annual_income).compact.sum
      yield_on_value = market_value.positive? ? (est_annual_income / market_value) * 100 : 0

      summary.merge({
                      yield_on_value: yield_on_value,
                      total_cost: total_cost,
                      market_value: market_value,
                      gain_loss: gain_loss,
                      gain_loss_pct: gain_loss_pct,
                      est_annual_income: est_annual_income
                    })
    end
  end
end

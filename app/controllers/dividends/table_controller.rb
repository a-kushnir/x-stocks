# frozen_string_literal: true

module Dividends
  # Table representation of user portfolio dividends
  class TableController < ApplicationController
    memorize_params :datatable_dividends, only: [:index] do
      params.permit(:items, columns: [])
    end

    def index
      positions = XStocks::AR::Position.joins(:stock).with_user(current_user).with_shares

      @table = table
      @table.sort { |column, direction| positions = positions.reorder(column => direction) }
      @table.filter { |query| positions = positions.where('LOWER(stocks.symbol) like LOWER(:query) or LOWER(stocks.company_name) like LOWER(:query)', query: "%#{query}%") }

      positions = positions.all
      positions = @table.paginate(positions)
      return unless stale?(positions)

      rows, @summary = data(positions)
      @table.rows.concat(rows)
      @summary_row = [
        # Stock
        nil,
        nil,
        nil,
        @summary[:yield_on_value],
        nil,
        @summary[:dividend_rating],
        # Position
        @summary[:total_cost],
        @summary[:market_value],
        @summary[:gain_loss],
        @summary[:gain_loss_pct],
        100,
        *@summary[:month_amounts],
        @summary[:total_amount]
      ]

      @page_title = 'My Dividends'
      @page_menu_item = :dividends
    end

    private

    def month_names
      @month_names ||=
        ::Dividend.new.months.each_with_index.map do |month, index|
          (index.zero? || index == 11 ? month.strftime("%b'%y") : month.strftime('%b'))
        end
    end

    def table
      table = DataTable::Table.new(params, DataTable::Table::DEFAULT_PAGINATION_OPTIONS + [['All', -1]])

      table.init_columns do |columns|
        # Stock
        columns << DataTable::Column.new(code: 'smb', label: 'Symbol', formatter: 'stock_link', sorting: 'stocks.symbol', default: true)
        columns << DataTable::Column.new(code: 'cmp', label: 'Company', formatter: 'string', sorting: 'stocks.company_name', default: true)
        columns << DataTable::Column.new(code: 'cnt', label: 'Country', formatter: 'string', align: 'center', sorting: 'stocks.country')
        columns << DataTable::Column.new(code: 'yld', label: 'Est. Yield %', formatter: 'percent_or_warning2', sorting: 'stocks.est_annual_dividend_pct', default: true)
        columns << DataTable::Column.new(code: 'dch', label: 'Div. Change', formatter: 'percent_delta1')
        columns << DataTable::Column.new(code: 'dsf', label: 'Div. Safety', formatter: 'safety_badge', sorting: 'stocks.dividend_rating', default: true)
        # Position
        columns << DataTable::Column.new(code: 'cst', label: 'Total Cost', formatter: 'currency', sorting: 'positions.total_cost')
        columns << DataTable::Column.new(code: 'mvl', label: 'Market Value', formatter: 'currency', sorting: 'positions.market_value')
        columns << DataTable::Column.new(code: 'trc', label: 'Total Return', formatter: 'currency_delta', sorting: 'positions.gain_loss')
        columns << DataTable::Column.new(code: 'trp', label: 'Total Return %', formatter: 'percent_delta2', sorting: 'positions.gain_loss_pct')
        columns << DataTable::Column.new(code: 'dvr', label: 'Diversity %', formatter: 'percent2', sorting: 'positions.market_value')
        # Dividends
        month_names.each_with_index do |month_name, index|
          columns << DataTable::Column.new(code: "m#{index.to_s.rjust(2, '0')}", label: month_name, formatter: 'currency', default: true)
        end
        columns << DataTable::Column.new(code: 'ttl', label: 'Total', formatter: 'currency_or_warning', default: true)
      end
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
          stock.symbol,
          stock.company_name,
          flag.code(stock.country),
          value_or_warning(div_suspended, stock.est_annual_dividend_pct&.to_f),
          stock.div_change_pct&.round(1),
          div_suspended ? 0 : stock.dividend_rating&.to_f,
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

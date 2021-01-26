# frozen_string_literal: true

# Controller to provide dividend information for user's portfolio
class DividendsController < ApplicationController
  helper :stocks

  def index
    @positions = XStocks::AR::Position
                 .where(user: current_user)
                 .where.not(shares: nil)
                 .all

    @columns = columns
    @data, @summary = data(@positions)

    @page_title = 'My Dividends'
    @page_menu_item = :dividends

    respond_to do |format|
      format.html {}
      format.xlsx { generate_xlsx }
    end
  end

  private

  def generate_xlsx
    send_tmp_file('Dividends.xlsx') do |file_name|
      XLSX::Dividends.new.generate(file_name, @positions)
    end
  end

  def columns
    div = ::Dividend.new
    month_names = []
    div.months.each_with_index do |month, index|
      month_names << (index.zero? || index == 11 ? month.strftime("%b'%y") : month.strftime('%b'))
    end

    columns = []
    # Stock
    columns << { label: 'Company', align: 'left', searchable: true, default: true }
    columns << { label: 'Est. Yield %', default: true }
    columns << { label: 'Div. Change' }
    columns << { label: 'Div. Safety', align: 'center', default: true }
    # Position
    columns << { label: 'Total Cost' }
    columns << { label: 'Market Value' }
    columns << { label: 'Gain/Loss' }
    columns << { label: 'Gain/Loss %' }
    columns << { label: 'Diversity %' }
    # Dividends
    month_names.each do |month_name|
      columns << { label: month_name, default: true }
    end
    columns << { label: 'Total', default: true }

    columns.each_with_index { |column, index| column[:index] = index + 1 }
    columns
  end

  def data(positions)
    model = XStocks::Stock.new
    dividend = ::Dividend.new
    months = dividend.months

    stocks = XStocks::AR::Stock.where(id: positions.map(&:stock_id)).all
    stocks = stocks.index_by(&:id)

    total_market_value = positions.sum(&:market_value)
    month_amounts = months.map { 0 }
    avg_dividend_rating = XStocks::Position::AvgDividendRating.new

    data = []
    positions.each do |position|
      stock = stocks[position.stock_id]
      div_suspended = model.div_suspended?(stock)
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
    model = XStocks::Stock.new
    diversity = position.market_value && total_market_value ? (position.market_value / total_market_value * 100).round(2) : nil

    result =
      [
        # Stock
        [stock.symbol, stock.logo, position.note.presence],
        stock.company_name,
        value_or_warning(div_suspended, stock.est_annual_dividend_pct&.to_f),
        model.div_change_pct(stock)&.round(1),
        stock.dividend_rating&.to_f,
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

    amount = estimates.detect { |e| e[:month] == month }&.dig(:amount)
    (amount * position.shares).round(2).to_f if amount
  end

  def annual_dividends(estimates, div_suspended, position)
    return nil if div_suspended

    amount = estimates.map { |estimate| estimate[:amount] }.sum
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

# frozen_string_literal: true

# Controller to provide position information for user's portfolio
class PositionsController < ApplicationController
  def index
    @positions = XStocks::AR::Position
                 .where(user: current_user)
                 .where.not(shares: nil)
                 .all
    return unless stale?(@positions)

    @columns = columns
    @positions = @positions.to_a
    @data, @summary = data(@positions)

    @page_title = 'My Positions'
    @page_menu_item = :positions

    respond_to do |format|
      format.html {}
      format.xlsx { generate_xlsx }
    end
  end

  def update
    @position = find_position
    not_found && return unless @position

    @position.attributes = position_params
    if XStocks::Position.new.save(@position)
      render partial: 'show', layout: nil
    else
      render partial: 'edit', layout: nil
    end
  rescue Exception => e
    internal_error(e, layout: nil)
  end

  private

  def find_position
    stock = XStocks::AR::Stock.find_by(symbol: params[:id])
    XStocks::AR::Position.find_or_initialize_by(user: current_user, stock: stock) if stock
  end

  def position_params
    params
      .require(:x_stocks_ar_position)
      .permit(:shares, :average_price, :stop_loss, :note)
  end

  def generate_xlsx
    send_tmp_file('Positions.xlsx') do |file_name|
      XLSX::Positions.new.generate(file_name, @positions)
    end
  end

  def columns
    columns = []

    # Stock
    columns << { label: 'Company', align: 'left', searchable: true, default: true }
    columns << { label: 'Country', align: 'center' }
    # Position
    columns << { label: 'Shares', default: true }
    columns << { label: 'Average Price', default: true }
    columns << { label: 'Market Price', default: true }
    columns << { label: 'Total Cost', default: true }
    columns << { label: 'Market Value', default: true }
    columns << { label: 'Gain/Loss', default: true }
    columns << { label: 'Gain/Loss %', default: true }
    columns << { label: 'Annual Div.', default: true }
    columns << { label: 'Diversity %', default: true }
    # Stop Loss
    columns << { label: 'Stop Price' }
    columns << { label: 'Est. Credit' }
    columns << { label: 'Est. Gain/Loss' }
    columns << { label: 'Est. Gain/Loss %' }
    # Stock
    columns << { label: 'Price' }
    columns << { label: 'Change' }
    columns << { label: 'Change %' }
    columns << { label: '52 Week Range' }
    columns << { label: 'Fair Value' }
    columns << { label: 'Est. Annual Div.' }
    columns << { label: 'Est. Yield %' }
    columns << { label: 'Div. Change %' }
    columns << { label: 'P/E Ratio' }
    columns << { label: 'Payout %' }
    columns << { label: 'Yahoo Rec.' }
    columns << { label: 'Finnhub Rec.' }
    columns << { label: 'Div. Safety' }
    columns << { label: 'Ex Date' }
    columns << { label: 'Score', align: 'center' }

    columns.each_with_index { |column, index| column[:index] = index + 1 }
    columns
  end

  def data(positions)
    stocks = XStocks::Stock.find_all(id: positions.map(&:stock_id))
    @stocks_by_id = stocks.index_by(&:id)

    total_market_value = positions.sum(&:market_value)
    avg_dividend_rating = XStocks::Position::AvgDividendRating.new

    data = []
    positions.each do |position|
      stock = @stocks_by_id[position.stock_id]
      div_suspended = stock.div_suspended?
      avg_dividend_rating.add(stock.dividend_rating, div_suspended, position.market_value)

      data << row(stock, position, div_suspended, total_market_value)
    end

    summary = {
      dividend_rating: avg_dividend_rating.value
    }

    [data, summary(positions, summary)]
  end

  def row(stock, position, div_suspended, total_market_value)
    diversity = position.market_value && total_market_value ? (position.market_value / total_market_value * 100).round(2) : nil
    flag = CountryFlag.new

    [
      # Stock
      [stock.symbol, stock.logo, position.note.presence],
      stock.company_name,
      flag.code(stock.country),
      # Position
      position.shares&.to_f,
      position.average_price&.to_f,
      position.market_price&.to_f,
      position.total_cost&.to_f,
      position.market_value&.to_f,
      position.gain_loss&.to_f,
      position.gain_loss_pct&.to_f,
      position.est_annual_income&.to_f,
      diversity&.to_f,
      # Stop Loss
      position.stop_loss&.to_f,
      position.stop_loss_value&.to_f,
      position.stop_loss_gain_loss&.to_f,
      position.stop_loss_gain_loss_pct&.to_f,
      # Stock
      stock.current_price&.to_f,
      stock.price_change&.to_f,
      stock.price_change_pct&.to_f,
      stock.price_range,
      stock.yahoo_discount&.to_f,
      value_or_warning(div_suspended, stock.est_annual_dividend&.to_f),
      value_or_warning(div_suspended, stock.est_annual_dividend_pct&.to_f),
      stock.div_change_pct&.round(1),
      stock.pe_ratio_ttm&.to_f&.round(2),
      stock.payout_ratio&.to_f,
      stock.yahoo_rec&.to_f,
      stock.finnhub_rec&.to_f,
      stock.dividend_rating&.to_f,
      stock.next_div_ex_date && !stock.next_div_ex_date.past? ? stock.next_div_ex_date : nil,
      [stock.metascore, stock.meta_score_details]
    ]
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

    stop_loss_positions = positions.select(&:stop_loss_value)
    stop_loss_value = stop_loss_positions.map(&:stop_loss_value).sum || 0
    stop_loss_gain_loss = stop_loss_positions.map(&:stop_loss_gain_loss).sum || 0
    stop_loss_market_value = stop_loss_positions.sum(&:market_value) || 0
    stop_loss_gain_loss_pct = stop_loss_market_value.positive? ? (stop_loss_gain_loss / stop_loss_market_value) * 100 : 0

    summary.merge({
                    total_cost: total_cost,
                    market_value: market_value,
                    gain_loss: gain_loss,
                    gain_loss_pct: gain_loss_pct,
                    est_annual_income: est_annual_income,
                    yield_on_value: yield_on_value,
                    stop_loss_value: stop_loss_value,
                    stop_loss_gain_loss: stop_loss_gain_loss,
                    stop_loss_gain_loss_pct: stop_loss_gain_loss_pct
                  })
  end
end

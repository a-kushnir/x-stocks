# frozen_string_literal: true

# Controller to provide position information for user's portfolio
class PositionsController < ApplicationController
  def index
    @positions = XStocks::AR::Position
                 .where(user: current_user)
                 .where.not(shares: nil)
                 .all.to_a

    @columns = columns
    @data = data(@positions)
    @summary = summary(@positions)

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
      .permit(:shares, :average_price, :note)
  end

  def generate_xlsx
    send_tmp_file('Positions.xlsx') do |file_name|
      XLSX::Positions.new.generate(file_name, @positions)
    end
  end

  def columns
    columns = []

    # Position
    columns << { label: 'Shares', index: index = 1, default: true }
    columns << { label: 'Average Price', index: index += 1, default: true }
    columns << { label: 'Market Price', index: index += 1, default: true }
    columns << { label: 'Total Cost', index: index += 1, default: true }
    columns << { label: 'Market Value', index: index += 1, default: true }
    columns << { label: 'Gain/Loss', index: index += 1, default: true }
    columns << { label: 'Gain/Loss %', index: index += 1, default: true }
    columns << { label: 'Annual Dividend', index: index += 1, default: true }
    columns << { label: 'Diversity %', index: index += 1, default: true }
    # Stock
    columns << { label: 'Price', index: index += 1 }
    columns << { label: 'Change', index: index += 1 }
    columns << { label: 'Change %', index: index += 1 }
    columns << { label: 'Fair Value', index: index += 1 }
    columns << { label: 'Est. Annual Div.', index: index += 1 }
    columns << { label: 'Est. Field %', index: index += 1 }
    columns << { label: 'Div. Change %', index: index += 1 }
    columns << { label: 'P/E Ratio', index: index += 1 }
    columns << { label: 'Payout %', index: index += 1 }
    columns << { label: 'Yahoo Rec.', index: index += 1 }
    columns << { label: 'Finnhub Rec.', index: index += 1 }
    columns << { label: 'Div. Safety', index: index += 1 }
    columns << { label: 'Ex Date', index: index += 1 }
    columns << { label: 'Score', index: index + 1 }

    columns
  end

  def data(positions)
    model = XStocks::Stock.new

    stocks = XStocks::AR::Stock.where(id: positions.map(&:stock_id)).all
    stocks = stocks.index_by(&:id)

    market_value = positions.sum(&:market_value)

    positions.map do |position|
      stock = stocks[position.stock_id]
      diversity = position.market_value && market_value ? (position.market_value / market_value * 100).round(2) : nil

      [
        # Position
        [stock.symbol, stock.logo, position.note.presence],
        position.shares&.to_f,
        position.average_price&.to_f,
        position.market_price&.to_f,
        position.total_cost&.to_f,
        position.market_value&.to_f,
        position.gain_loss&.to_f,
        position.gain_loss_pct&.to_f,
        position.est_annual_income&.to_f,
        diversity&.to_f,
        # Stock
        stock.current_price&.to_f,
        stock.price_change&.to_f,
        stock.price_change_pct&.to_f,
        stock.yahoo_discount&.to_f,
        stock.est_annual_dividend&.to_f,
        stock.est_annual_dividend_pct&.to_f,
        model.div_change_pct(stock)&.round(1),
        stock.pe_ratio_ttm&.to_f&.round(2),
        stock.payout_ratio&.to_f,
        stock.yahoo_rec&.to_f,
        stock.finnhub_rec&.to_f,
        stock.dividend_rating&.to_f,
        stock.next_div_ex_date && !stock.next_div_ex_date.past? ? stock.next_div_ex_date : nil,
        [stock.metascore, model.metascore_details(stock)]
      ]
    end
  end

  def summary(positions)
    total_cost = positions.map(&:total_cost).compact.sum || 0
    market_value = positions.map(&:market_value).compact.sum || 0
    gain_loss = market_value - total_cost
    gain_loss_pct = total_cost.positive? ? gain_loss / total_cost * 100 : 0

    {
      total_cost: total_cost,
      market_value: market_value,
      gain_loss: gain_loss,
      gain_loss_pct: gain_loss_pct,
      est_annual_income: positions.map(&:est_annual_income).compact.sum
    }
  end
end

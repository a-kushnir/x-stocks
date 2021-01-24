# frozen_string_literal: true

# Controller to provide stock information
class StocksController < ApplicationController
  include StocksHelper

  def index
    return if handle_goto_param?

    stock_ids = handle_tag_param

    @stocks = XStocks::AR::Stock
    @stocks = @stocks.where(id: stock_ids) if @tag
    @stocks = @stocks.all.to_a

    @positions = XStocks::AR::Position.where(stock: @stocks, user: current_user).all

    @columns = columns
    @data = data

    @page_title = 'Stocks'
    @page_menu_item = :stocks
  end

  def show
    @stock = find_stock
    not_found && return unless @stock

    begin
      Etl::Refresh::Finnhub.new.hourly_one_stock!(@stock)
    rescue StandardError
      nil
    end
    @position = XStocks::AR::Position.find_or_initialize_by(stock: @stock, user: current_user)

    set_page_title
  end

  def new
    @stock = XStocks::AR::Stock.new
    set_page_title
  end

  def create
    @stock = XStocks::AR::Stock.new(stock_params)

    if XStocks::Stock.new.save(@stock)
      XStocks::Service.new.lock(:company_information, force: true) do |logger|
        logger.text_size_limit = nil
        Etl::Refresh::Company.new.one_stock!(@stock, logger: logger)
      end

      redirect_to stock_path(@stock)
    else
      set_page_title
      render action: 'new'
    end
  end

  def destroy
    @stock = find_stock
    not_found && return unless @stock

    if XStocks::Stock.new.destroyable?(@stock)
      @stock.destroy
      flash[:notice] = "#{XStocks::Stock.new.to_s(@stock)} stock deleted"
      redirect_to stocks_path
    else
      redirect_to stock_path(@stock)
    end
  end

  private

  def set_page_title
    @page_title = @stock.new_record? ? 'New Stock' : XStocks::Stock.new.to_s(@stock)
    @page_menu_item = :stocks
  end

  def find_stock
    XStocks::AR::Stock.find_by(symbol: params[:id])
  end

  def stock_params
    params.require(:x_stocks_ar_stock).permit(:symbol)
  end

  def handle_goto_param?
    value = params[:goto]
    return false if value.blank?

    stock = XStocks::AR::Stock.find_by(symbol: value.upcase)
    if stock
      redirect_to stock_path(stock)
      return true
    end

    stocks = XStocks::AR::Stock.where('company_name ILIKE ?', "%#{value.downcase}%").all
    if stocks.count == 1
      redirect_to stock_path(stocks.first)
      return true
    end

    redirect_to url_for(search: value)
    true
  end

  def handle_tag_param
    @tag = params[:tag]
    return if @tag.blank?

    virtual_tag = VirtualTag.find(@tag)

    stock_ids =
      if virtual_tag
        virtual_tag.find_stock_ids(current_user)
      else
        XStocks::AR::Tag.where(name: @tag).pluck(:stock_id)
      end

    @tag = nil if stock_ids.blank? && !virtual_tag
    stock_ids
  end

  def columns
    columns = []

    columns << { label: 'Company', index: index = 1, default: true }
    columns << { label: 'Price', index: index += 1, default: true }
    columns << { label: 'Change', index: index += 1, default: true }
    columns << { label: 'Change %', index: index += 1, default: true }
    columns << { label: 'Fair Value', index: index += 1, default: true }
    columns << { label: 'Est. Annual Div.', index: index += 1, default: true }
    columns << { label: 'Est. Field %', index: index += 1, default: true }
    columns << { label: 'Div. Change %', index: index += 1 }
    columns << { label: 'P/E Ratio', index: index += 1 }
    columns << { label: 'Payout %', index: index += 1 }
    columns << { label: 'Yahoo Rec.', index: index += 1, default: true }
    columns << { label: 'Finnhub Rec.', index: index += 1, default: true }
    columns << { label: 'Div. Safety', index: index += 1, default: true }
    columns << { label: 'Ex Date', index: index += 1 }
    columns << { label: 'Score', index: index + 1, default: true }

    columns
  end

  def data
    data = []

    model = XStocks::Stock.new

    positions = {}
    @positions.each do |position|
      positions[position.stock_id] = position
    end

    @stocks.each do |stock|
      position = positions[stock.id]
      data << [
        [stock.symbol, stock.logo, position&.note.presence],
        stock.company_name,
        stock.current_price,
        stock.price_change,
        stock.price_change_pct,
        stock.yahoo_discount,
        stock.est_annual_dividend,
        stock.est_annual_dividend_pct,
        model.div_change_pct(stock)&.round(1),
        stock.pe_ratio_ttm&.round(2),
        stock.payout_ratio,
        stock.yahoo_rec,
        stock.finnhub_rec,
        stock.dividend_rating,
        stock.next_div_ex_date && !stock.next_div_ex_date.past? ? stock.next_div_ex_date : nil,
        [stock.metascore, model.metascore_details(stock)]
      ]
    end

    data
  end
end

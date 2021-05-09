# frozen_string_literal: true

# Controller to provide stock information
class StocksController < ApplicationController
  include ActionController::Live
  include StocksHelper

  UPDATE_PRICE_TIMEOUT = 0.5 # sec

  def index
    return if handle_goto_param?

    stock_ids = handle_tag_param

    stocks = XStocks::AR::Stock
    stocks = stocks.where(id: stock_ids) if @tag
    stocks = stocks.all
    return unless stale?(stocks)

    @columns = columns
    stocks = stocks.map { |stock| XStocks::Stock.new(stock) }
    @data = data(stocks)

    @page_title = 'Stocks'
    @page_menu_item = :stocks
  end

  def show
    @stock = find_stock
    not_found && return unless @stock

    @stock.reload if update_price
    @position = XStocks::AR::Position.find_or_initialize_by(stock_id: @stock.id, user: current_user)

    set_page_title
  end

  def new
    @stock = new_stock
    set_page_title
  end

  def create
    @stock = new_stock
    @stock.attributes = create_stock_params

    if @stock.save
      redirect_to action: 'initializing', id: @stock.symbol
    else
      set_page_title
      render action: 'new'
    end
  end

  def edit
    @stock = find_stock
    not_found && return unless @stock

    @exchanges = XStocks::AR::Exchange.all
    set_page_title
  end

  def update
    @stock = find_stock
    not_found && return unless @stock

    @stock.attributes = update_stock_params
    if @stock.save
      redirect_to action: 'show', id: @stock.symbol
    else
      @exchanges = XStocks::AR::Exchange.all
      set_page_title
      render action: 'edit'
    end
  end

  def initializing
    set_page_title
    @stock = find_stock
    not_found unless @stock
  end

  def processing
    EventStream.run(response) do |stream|
      @stock = XStocks::Stock.find_by!(symbol: params[:id])
      XStocks::Jobs::CompanyOne.new.perform(stock_id: @stock.id) { |status| stream.write(status) }
    end
  end

  def destroy
    stock = find_stock
    not_found && return unless stock

    if stock.destroyable?
      stock.destroy
      flash[:notice] = "#{stock} stock deleted"
      redirect_to stocks_path
    else
      redirect_to stock_path(stock)
    end
  end

  private

  def update_price
    safe_exec do
      Timeout::timeout(UPDATE_PRICE_TIMEOUT) do
        XStocks::Jobs::FinnhubPriceOne.new.perform(stock_id: @stock.id) { nil }
      end
      true
    end
  end

  def set_page_title
    @page_title = @stock.nil? || @stock.new_record? ? 'New Stock' : @stock
    @page_menu_item = :stocks
  end

  def new_stock
    XStocks::Stock.new(XStocks::AR::Stock.new)
  end

  def find_stock
    XStocks::Stock.find_by_symbol(params[:id])
  end

  def create_stock_params
    params.require(:x_stocks_ar_stock).permit(:symbol)
  end

  def update_stock_params
    params.require(:x_stocks_ar_stock).permit(:company_name, :exchange_id, :yahoo_fair_price)
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

    columns << { label: 'Company', align: 'left', searchable: true, default: true }
    columns << { label: 'Country', align: 'center' }
    columns << { label: 'Price', default: true }
    columns << { label: 'Change', default: true }
    columns << { label: 'Change %', default: true }
    columns << { label: '52 Week Range' }
    columns << { label: 'Fair Value', default: true }
    columns << { label: 'Short Term' }
    columns << { label: 'Mid Term' }
    columns << { label: 'Long Term' }
    columns << { label: 'Div. Frequency' }
    columns << { label: 'Est. Annual Div.', default: true }
    columns << { label: 'Est. Yield %', default: true }
    columns << { label: 'Div. Change %' }
    columns << { label: 'P/E Ratio' }
    columns << { label: 'Payout %' }
    columns << { label: 'Market Cap.' }
    columns << { label: 'Yahoo Rec.', default: true }
    columns << { label: 'Finnhub Rec.', default: true }
    columns << { label: 'Div. Safety', default: true }
    columns << { label: 'Ex Date' }
    columns << { label: 'Score', align: 'center', default: true }

    columns.each_with_index { |column, index| column[:index] = index + 1 }
    columns
  end

  def data(stocks)
    positions = XStocks::AR::Position.where(stock_id: stocks.map(&:id), user: current_user).all
    positions = positions.index_by(&:stock_id)
    flag = CountryFlag.new

    stocks.map do |stock|
      position = positions[stock.id]
      div_suspended = stock.div_suspended?
      [
        [stock.symbol, stock.logo_url, position&.note.presence],
        stock.company_name,
        flag.code(stock.country),
        stock.current_price&.to_f,
        stock.price_change&.to_f,
        stock.price_change_pct&.to_f,
        stock.price_range,
        stock.yahoo_discount&.to_f,
        stock.yahoo_short_direction,
        stock.yahoo_medium_direction,
        stock.yahoo_long_direction,
        [stock.dividend_frequency&.titleize, stock.dividend_frequency_num],
        value_or_warning(div_suspended, stock.est_annual_dividend&.to_f),
        value_or_warning(div_suspended, stock.est_annual_dividend_pct&.to_f),
        stock.div_change_pct&.round(1),
        stock.pe_ratio_ttm&.to_f&.round(2),
        stock.payout_ratio&.to_f,
        stock.market_capitalization&.to_f,
        stock.yahoo_rec&.to_f,
        stock.finnhub_rec&.to_f,
        stock.dividend_rating&.to_f,
        stock.prev_month_ex_date? ? stock.next_div_ex_date : nil,
        [stock.metascore, stock.meta_score_details]
      ]
    end
  end

  def value_or_warning(div_suspended, value)
    div_suspended ? 'Sus.' : value
  end

  def safe_exec
    yield
  rescue StandardError
    nil
  end
end

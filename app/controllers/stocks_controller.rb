# frozen_string_literal: true

# Controller to provide stock information
class StocksController < ApplicationController
  include ActionController::Live
  include StocksHelper

  UPDATE_PRICE_TIMEOUT = 0.5 # sec

  memorize_params :datatable_stocks, only: [:index] do
    params.permit(:items, columns: [])
  end

  def index
    return if handle_goto_param?

    stocks = XStocks::AR::Stock
    stocks = stocks.where(id: stock_ids) if @tag

    @table = table
    @table.sort { |column, direction| stocks = stocks.reorder(column => direction) }
    @table.filter { |query| stocks = stocks.where('LOWER(stocks.symbol) like LOWER(:query) or LOWER(stocks.company_name) like LOWER(:query)', query: "%#{query}%") }

    stocks = stocks.all
    stocks = @table.paginate(stocks)
    return unless stale?(stocks)

    populate_data(stocks)

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
      redirect_to({ action: 'initializing', symbol: @stock.symbol }.merge(initialize_params))
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
      redirect_to action: 'show'
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
    @stock = find_stock
    flash[:notice] = "#{@stock} stock added"
    EventStream.run(response) do |stream|
      XStocks::Jobs::CompanyOne.new.perform(symbol: @stock.id) { |status| stream.write(status) }
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
      redirect_to stock_path(stock.symbol)
    end
  end

  private

  def table
    table = DataTable::Table.new(params)

    table.init_columns do |columns|
      # Stock
      columns << DataTable::Column.new(code: 'smb', label: 'Symbol', formatter: 'stock_link', sorting: 'stocks.symbol', default: true)
      columns << DataTable::Column.new(code: 'cmp', label: 'Company', formatter: 'string', sorting: 'stocks.company_name', default: true)
      columns << DataTable::Column.new(code: 'cnt', label: 'Country', formatter: 'string', align: 'center', sorting: 'stocks.country')
      columns << DataTable::Column.new(code: 'prc', label: 'Price', formatter: 'currency', default: true)
      columns << DataTable::Column.new(code: 'prd', label: 'Change', formatter: 'currency_delta', default: true)
      columns << DataTable::Column.new(code: 'prp', label: 'Change %', formatter: 'percent_delta2', default: true)
      columns << DataTable::Column.new(code: 'wkr', label: '52 Week Range', formatter: 'price_range')
      columns << DataTable::Column.new(code: 'frv', label: 'Fair Value', formatter: 'percent_delta0', sorting: 'stocks.yahoo_discount', default: true)
      columns << DataTable::Column.new(code: 'srg', label: 'Short Term', formatter: 'direction', sorting: 'stocks.yahoo_short_direction')
      columns << DataTable::Column.new(code: 'mrg', label: 'Mid Term', formatter: 'direction', sorting: 'stocks.yahoo_medium_direction')
      columns << DataTable::Column.new(code: 'lrg', label: 'Long Term', formatter: 'direction', sorting: 'stocks.yahoo_long_direction')
      columns << DataTable::Column.new(code: 'dvf', label: 'Div. Frequency', formatter: 'string', sorting: 'stocks.dividend_frequency_num')
      columns << DataTable::Column.new(code: 'ndv', label: 'Next Div.', formatter: 'currency_or_warning4', sorting: 'stocks.next_div_amount')
      columns << DataTable::Column.new(code: 'ead', label: 'Est. Annual Div.', formatter: 'currency_or_warning', default: true)
      columns << DataTable::Column.new(code: 'eyp', label: 'Est. Yield %', formatter: 'percent_or_warning2', default: true)
      columns << DataTable::Column.new(code: 'dcp', label: 'Div. Change %', formatter: 'percent_delta1')
      columns << DataTable::Column.new(code: 'per', label: 'P/E Ratio', formatter: 'number2', sorting: 'stocks.pe_ratio_ttm')
      columns << DataTable::Column.new(code: 'ptp', label: 'Payout %', formatter: 'percent2', sorting: 'stocks.payout_ratio')
      columns << DataTable::Column.new(code: 'cap', label: 'Market Cap.', formatter: 'big_currency', sorting: 'stocks.market_capitalization')
      columns << DataTable::Column.new(code: 'yrc', label: 'Yahoo Rec.', formatter: 'recommendation', sorting: 'stocks.yahoo_rec')
      columns << DataTable::Column.new(code: 'frc', label: 'Finnhub Rec.', formatter: 'recommendation', sorting: 'stocks.finnhub_rec')
      columns << DataTable::Column.new(code: 'dsf', label: 'Div. Safety.', formatter: 'safety_badge', sorting: 'stocks.dividend_rating')
      columns << DataTable::Column.new(code: 'exd', label: 'Ex Date.', formatter: 'future_date', sorting: 'stocks.next_div_ex_date')
    end
  end

  def initialize_params
    params.permit(:save_and_show, :save_only).slice(:save_and_show, :save_only)
  end

  def update_price
    safe_exec do
      Timeout.timeout(UPDATE_PRICE_TIMEOUT) do
        XStocks::Jobs::FinnhubPriceOne.new.perform(symbol: @stock.id) { nil }
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
    XStocks::Stock.find_by_symbol(params[:symbol])
  end

  def create_stock_params
    params.require(:x_stocks_ar_stock).permit(:symbol)
  end

  def update_stock_params
    { taxes: [] }.merge(params.require(:x_stocks_ar_stock).permit(:company_name, :exchange_id, :yahoo_fair_price, taxes: []))
  end

  def handle_goto_param?
    value = params[:goto]
    return false if value.blank?

    stock = XStocks::AR::Stock.find_by(symbol: value.upcase)
    if stock
      redirect_to stock_path(stock.symbol)
      return true
    end

    stocks = XStocks::AR::Stock.where('company_name ILIKE ?', "%#{value.downcase}%").all
    if stocks.count == 1
      redirect_to stock_path(stocks.first.symbol)
      return true
    end

    redirect_to url_for(q: value)
    true
  end

  def stock_ids
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

  def populate_data(stocks)
    # positions = XStocks::AR::Position.where(stock_id: stocks.map(&:id), user: current_user).all
    # positions = positions.index_by(&:stock_id)
    flag = CountryFlag.new

    stocks.map do |stock|
      # position = positions[stock.id]
      @table.rows << row(stock, flag)
    end
  end

  def row(stock, flag)
    stock = XStocks::Stock.new(stock)
    div_suspended = stock.div_suspended?
    [
      stock.symbol,
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
      stock.dividend_frequency&.titleize,
      stock.next_div_amount&.to_f,
      value_or_warning(div_suspended, stock.est_annual_dividend&.to_f),
      value_or_warning(div_suspended, stock.est_annual_dividend_pct&.to_f),
      stock.div_change_pct&.round(1),
      stock.pe_ratio_ttm&.to_f&.round(2),
      stock.payout_ratio&.to_f,
      stock.market_capitalization&.to_f,
      stock.yahoo_rec&.to_f,
      stock.finnhub_rec&.to_f,
      stock.dividend_rating&.to_f,
      stock.prev_month_ex_date? ? stock.next_div_ex_date : nil
    ]
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

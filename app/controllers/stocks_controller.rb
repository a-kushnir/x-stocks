# frozen_string_literal: true

# Controller to provide stock information
class StocksController < ApplicationController
  include ActionController::Live
  include StocksControllerConcern
  include StocksHelper

  UPDATE_PRICE_TIMEOUT = 0.5 # sec

  memorize_params :datatable_stocks, only: [:index] do
    params.permit(:items, columns: [])
  end

  def index
    return if handle_goto_param?

    stocks = XStocks::AR::Stock
    stocks = stocks.where(id: stock_ids) if @tag

    @table = stock_table
    @table.sort { |column, direction| stocks = stocks.reorder(column => direction) }
    @table.filter { |query| stocks = stocks.where('LOWER(stocks.symbol) like LOWER(:query) or LOWER(stocks.company_name) like LOWER(:query)', query: "%#{query}%") }

    stocks = stocks.all
    stocks = @table.paginate(stocks)
    return unless stale?(stocks)

    stocks.each { |stock| @table.rows << stock_table_row(stock) }

    @page_title = t('stocks.pages.stocks')
  end

  def show
    @stock = find_stock
    not_found && return unless @stock

    @stock.reload if update_price
    @position = XStocks::AR::Position.find_or_initialize_by(stock_id: @stock.id, user: current_user)
  end

  def new
    @stock = new_stock
  end

  def create
    @stock = new_stock
    @stock.attributes = create_stock_params

    if @stock.save
      redirect_to({ action: 'initializing', symbol: @stock.symbol })
    else
      render action: 'new'
    end
  end

  def edit
    @stock = find_stock
    not_found && return unless @stock

    @exchanges = XStocks::AR::Exchange.all
  end

  def update
    @stock = find_stock
    not_found && return unless @stock

    @stock.attributes = update_stock_params
    if @stock.save
      redirect_to action: 'show'
    else
      @exchanges = XStocks::AR::Exchange.all
      render action: 'edit'
    end
  end

  def initializing
    @stock = find_stock
    not_found unless @stock
  end

  def processing
    @stock = find_stock
    flash[:notice] = render_to_string partial: 'processed'

    EventStream.run(response) do |stream|
      XStocks::Jobs::CompanyOne.new(current_user).perform(symbol: @stock.symbol) { |status| stream.write(status) }
      stream.redirect_to(new_stock_path)
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

  def render(*args)
    @page_title ||= @stock && !@stock.new_record? ? @stock.to_s : t('stocks.pages.new_stock')
    @page_menu_item = :stocks
    super
  end

  def update_price
    safe_exec do
      Timeout.timeout(UPDATE_PRICE_TIMEOUT) do
        XStocks::Jobs::FinnhubPriceOne.new(current_user).perform(symbol: @stock.symbol) { nil }
      end
      true
    end
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
    value = params[:goto]&.strip
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

  def safe_exec
    yield
  rescue StandardError
    nil
  end
end

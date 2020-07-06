class StocksController < ApplicationController
  include StocksHelper

  before_action :authenticate_user!, except: [:index, :show]

  def index
    @page_title = 'Stocks'
    @stocks = Stock.all
  end

  def show
    @stock = find_stock
    not_found && return unless @stock

    set_page_title
  end

  def new
    @stock = Stock.new
    set_page_title
  end

  def create
    @stock = Stock.new(stock_params)
    if @stock.save
      update_stock_info(@stock)
      flash[:notice] = "#{@stock} stock created"
      redirect_to stock_path(@stock)
    else
      set_page_title
      render action: 'new'
    end
  end

  def edit
    @stock = find_stock
    not_found && return unless @stock

    set_page_title
  end

  def update
    @stock = find_stock
    not_found && return unless @stock

    if @stock.update(stock_params)
      update_stock_info(@stock)
      flash[:notice] = "#{@stock} stock updated"
      redirect_to stock_path(@stock)
    else
      set_page_title
      render action: 'edit'
    end
  end

  def destroy
    @stock = find_stock
    not_found && return unless @stock

    @stock.delete
    flash[:notice] = "#{@stock} stock deleted"
    redirect_to stocks_path
  end

  def test
    @stock = find_stock

    import = Import::Yahoo.new
    page = import.retrieve(@stock.symbol)
    send_data(page, filename: 'page.html', type: 'text/html')
  end

  private

  def set_page_title
    @page_title =
      if @stock.new_record?
        'New Stock'
      elsif @stock.company
        "#{@stock.company.company_name} (#{@stock.symbol})"
      else
        @stock.symbol
      end
  end

  def find_stock
    Stock.find_by(symbol: params[:id])
  end

  def stock_params
    params.require(:stock).permit(:symbol)
  end

  def update_stock_info?(stock)
    return true if stock.saved_change_to_symbol?
    return false unless stock.saved_change_to_updated_at?
    prev_updated_at = stock.saved_change_to_updated_at.first
    prev_updated_at.nil? || prev_updated_at < 7.days.ago
  end

  def update_stock_info(stock)
    if update_stock_info?(stock)
      json = Import::Iexapis.new.company(stock.symbol)
      Convert::Iexapis::Company.new.process(stock, json)
    end
  end
end

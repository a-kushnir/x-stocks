class StocksController < ApplicationController
  include StocksHelper

  def index
    @page_title = 'Stocks'
    @stocks = Stock.all
  end

  def show
    @stock = find_stock
    set_page_title
  end

  def new
    @stock = Stock.new
    set_page_title
  end

  def create
    @stock = Stock.new(stock_params)
    if @stock.save
      flash[:notice] = "#{@stock} stock created"
      redirect_to stock_path(@stock)
    else
      set_page_title
      render action: 'new'
    end
  end

  def edit
    @stock = find_stock
    set_page_title
  end

  def update
    @stock = find_stock

    if @stock.update(stock_params)
      flash[:notice] = "#{@stock} stock updated"
      redirect_to stock_path(@stock)
    else
      set_page_title
      render action: 'edit'
    end
  end

  def destroy
    @stock = find_stock

    if @stock
      @stock.delete
      flash[:notice] = "#{@stock} stock deleted"
    end

    redirect_to stocks_path
  end

  private

  def set_page_title
    @page_title = (@stock.new_record? ? 'New Stock' : @stock.symbol)
  end

  def find_stock
    Stock.find_by(symbol: params[:id])
  end

  def stock_params
    params.require(:stock).permit(:symbol)
  end
end

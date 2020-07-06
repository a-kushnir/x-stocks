class StocksController < ApplicationController
  def index
    @page_title = 'Stocks'
    @stocks = Stock.all
  end

  def show
    @stock = Stock.find(params[:id])
    set_page_title
  end

  def new
    @stock = Stock.new
    set_page_title
  end

  def create
    @stock = Stock.new(stock_params)
    if @stock.save
      redirect_to @stock
    else
      set_page_title
      render action: 'new'
    end
  end

  def edit
    @stock = Stock.find(params[:id])
    set_page_title
  end

  def update
    @stock = Stock.find(params[:id])

    if @stock.update(stock_params)
      redirect_to @stock
    else
      set_page_title
      render action: 'edit'
    end
  end

  def delete
    @stock = Stock.find(params[:id])
  end

  private

  def set_page_title
    @page_title = (@stock.new_record? ? 'New Stock' : @stock.symbol)
  end

  def stock_params
    params.require(:stock).permit(:symbol)
  end
end

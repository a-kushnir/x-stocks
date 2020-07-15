class StocksController < ApplicationController
  include StocksHelper

  def index
    @tag = params[:tag]
    stock_ids = @tag ? Tag.where(name: @tag).pluck(:stock_id) : []
    @tag = nil unless stock_ids.present?

    @stocks = Stock
    @stocks = @stocks.where(id: stock_ids) if stock_ids.present?
    @stocks = @stocks.all

    @page_title = 'Stocks'
    @page_menu_item = :stocks
  end

  def show
    @stock = find_stock
    not_found && return unless @stock

    Etl::Refresh::Finnhub.new.hourly_one_stock!(@stock) rescue nil

    set_page_title
  end

  def new
    @stock = Stock.new
    set_page_title
  end

  def create
    @stock = Stock.new(stock_params)

    if @stock.save
      Etl::Refresh::Company.new.one_stock!(@stock)

      flash[:notice] = "#{@stock} stock created"
      redirect_to stock_path(@stock)
    else
      set_page_title
      render action: 'new'
    end
  end

  def destroy
    @stock = find_stock
    not_found && return unless @stock

    @stock.destroy
    flash[:notice] = "#{@stock} stock deleted"
    redirect_to stocks_path
  end

  private

  def set_page_title
    @page_title = @stock.new_record? ? 'New Stock' : @stock.to_s
    @page_menu_item = :stocks
  end

  def find_stock
    Stock.find_by(symbol: params[:id])
  end

  def stock_params
    params.require(:stock).permit(:symbol)
  end

end

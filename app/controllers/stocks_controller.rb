class StocksController < ApplicationController
  include StocksHelper

  def index
    return if handle_goto_param?

    @tag = params[:tag]
    stock_ids = @tag ? Tag.where(name: @tag).pluck(:stock_id) : []
    @tag = nil unless stock_ids.present?

    @stocks = Stock
    @stocks = @stocks.where(id: stock_ids) if stock_ids.present?
    @stocks = @stocks.all

    @positions = Position.where(stock: @stocks, user: current_user).all

    @page_title = 'Stocks'
    @page_menu_item = :stocks
  end

  def show
    @stock = find_stock
    not_found && return unless @stock

    Etl::Refresh::Finnhub.new.hourly_one_stock!(@stock) rescue nil
    @position = Position.find_or_initialize_by(stock: @stock, user: current_user)

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

  def handle_goto_param?
    value = params[:goto]
    return false if value.blank?

    stock = Stock.find_by(symbol: value.upcase)
    if stock
      redirect_to stock_path(stock)
      return true
    end

    stocks = Stock.where('company_name ILIKE ?', "%#{value.downcase}%").all
    if stocks.count == 1
      redirect_to stock_path(stocks.first)
      return true
    end

    redirect_to url_for(search: value)
    true
  end

end

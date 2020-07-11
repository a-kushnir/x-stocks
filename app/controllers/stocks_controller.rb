class StocksController < ApplicationController
  include StocksHelper

  def index
    @stocks = Stock.all

    @page_title = 'Stocks'
    @page_menu_item = :stocks
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
      Etl::DataRefresh.new.company_data(@stock)
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
      Etl::DataRefresh.new.company_data(@stock)
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

    @stock.destroy
    flash[:notice] = "#{@stock} stock deleted"
    redirect_to stocks_path
  end

  def test
    @stock = find_stock

      #json = Etl::Extract::Finnhub.new.quote(@stock.symbol)
      #Etl::Transform::Finnhub.new.quote(@stock, json)

      #flash[:notice] = "#{@stock} stock price updated"
      #redirect_to stock_path(@stock)

    import = Etl::Extract::Yahoo.new
    json = import.statistics(@stock.symbol)
      # send_data(page, filename: 'page.html', type: 'text/html')
    a = 1
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

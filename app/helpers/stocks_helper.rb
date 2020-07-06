module StocksHelper

  def stock_path(stock)
    "/stocks/#{stock.symbol}"
  end

  def edit_stock_path(stock)
    "/stocks/#{stock.symbol}/edit"
  end
end

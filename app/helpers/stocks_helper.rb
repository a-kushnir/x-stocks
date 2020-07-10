module StocksHelper

  def stock_path(stock)
    "/stocks/#{stock.symbol}"
  end

  def edit_stock_path(stock)
    "/stocks/#{stock.symbol}/edit"
  end

  def link_to_website(url)
    link_to url.sub(/^https?\:\/\/(www.)?/,''), url if url
  end

  def stock_peers
    @stock.tags.by_key(:stock_peer).map do |tag|
      if tag.name != @stock.symbol
        { symbol: tag.name, stock: ::Stock.find_by(symbol: tag.name) }
      end
    end.compact
  end

end

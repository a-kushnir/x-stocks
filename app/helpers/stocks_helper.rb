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
      { symbol: tag.name, stock: ::Stock.find_by(symbol: tag.name) }
    end.compact
  end

  def yahoo_rec_human(value)
    if value.nil?
      nil
    elsif value <= 1.5
      'Str. Buy'
    elsif value <= 2.5
      'Buy'
    elsif value < 3.5
      'Hold'
    elsif value < 4.5
      'Sell'
    else
      'Str. Sell'
    end
  end

end

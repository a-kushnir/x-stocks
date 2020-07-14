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
    @stock.peers.map do |peer|
      @stock.symbol == peer ? nil : { symbol: peer, stock: ::Stock.find_by(symbol: peer) }
    end.compact
  end

  def rec_human(value)
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

  def rec_graph_data(details)
    {
      labels: details.keys.map { |date| Date.parse(date).strftime('%b') },
      datasets:
        [{
           label: 'Strong Sell',
           backgroundColor: '#FF333A',
           data: details.values.map { |value| value[4] }
        }, {
           label: 'Sell',
           backgroundColor: '#FFA33E',
           data: details.values.map { |value| value[3] }
        } , {
           label: 'Hold',
           backgroundColor: '#FFDC48',
           data: details.values.map { |value| value[2] }
        }, {
           label: 'Buy',
           backgroundColor: '#00C073',
           data: details.values.map { |value| value[1] }
        }, {
           label: 'Strong Buy',
           backgroundColor: '#008F88',
           data: details.values.map { |value| value[0] }
        }]
    }
  end

end

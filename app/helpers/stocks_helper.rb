# frozen_string_literal: true

# Helper methods for StocksController
module StocksHelper
  def stock_path(stock)
    "/stocks/#{CGI.escape(stock.symbol)}"
  end

  def edit_stock_path(stock)
    "/stocks/#{CGI.escape(stock.symbol)}/edit"
  end

  def link_to_website(url)
    link_to url.sub(%r{^https?://(www.)?}, ''), url if url
  end

  def stock_peers
    (@stock.peers || []).map do |peer|
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

  def safety_human(value)
    if value.nil?
      nil
    elsif value >= 4.5
      'Very Safe'
    elsif value >= 3.5
      'Safe'
    elsif value >= 2.5
      'Borderline'
    elsif value >= 1.5
      'Unsafe'
    else
      'Very Unsafe'
    end
  end

  def rec_min_visible_value(details)
    details.values.map(&:sum).max / 10
  rescue StandardError
    1
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
        }, {
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

  def position_allocation
    positions = @positions.reject { |pos| (pos.market_value || 0).zero? }
    positions = positions.sort_by(&:market_value).reverse
    values = positions.map { |p| p.market_value.to_f }
    labels = positions.map { |p| p.stock.symbol }
    [values, labels]
  end

  def sector_allocation
    sectors = {}
    positions = @positions.reject { |pos| (pos.market_value || 0).zero? }
    positions.each do |pos|
      sector = sectors[pos.stock.sector] ||= { sector: pos.stock.sector, value: 0, symbols: [] }
      sector[:value] += pos.market_value
      sector[:symbols] << pos.stock.symbol
    end
    sectors = sectors.values
    sectors = sectors.sort_by { |sector| -sector[:value] }
    values = sectors.map { |sector| sector[:value].to_f }
    labels = sectors.map { |sector| sector[:sector] }
    symbols = sectors.map { |sector| sector[:symbols].join(', ') }
    [values, labels, symbols]
  end

  def dividend_precision(amount)
    amount && amount.to_s == amount.round(2).to_s ? 2 : 4
  end

  def metascore_details(stock)
    return unless stock.metascore_details

    stock.metascore_details.map do |k, v|
      case k
      when 'yahoo_rec'
        "#{v['score']}: Yahoo Rec. #{v['value']} #{rec_human(v['value'])}"
      when 'finnhub_rec'
        "#{v['score']}: Finnhub Rec. #{v['value']} #{rec_human(v['value'])}"
      when 'payout_ratio'
        "#{v['score']}: Payout #{v['value']}%"
      when 'div_safety'
        "#{v['score']}: Div Safety #{v['value']}"
      else
        "#{v['score']}: #{k} #{v['value']}"
      end
    end.join("\n")
  end

  def metascore_color(value)
    if value > 80
      'rec-str-buy'
    elsif value > 60
      'rec-buy'
    elsif value > 40
      'rec-hold'
    elsif value > 20
      'rec-sell'
    else
      'rec-str-sell'
    end
  end

  def humanize_earnings_hour(value)
    {
      'bmo' => 'Before Market Open',
      'amc' => 'After Market Close',
      'dmh' => 'During Market Hours'
    }[value] || 'Unknown'
  end
end

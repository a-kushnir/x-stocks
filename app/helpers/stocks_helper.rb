# frozen_string_literal: true

# Helper methods for StocksController
module StocksHelper
  def stock_path(stock)
    "/stocks/#{CGI.escape(stock.symbol)}"
  end

  def edit_stock_path(stock)
    "/stocks/#{CGI.escape(stock.symbol)}/edit"
  end

  def processing_stock_path(stock)
    "/stocks/#{CGI.escape(stock.symbol)}/processing"
  end

  def link_to_website(url)
    label = url.sub(%r{^https?://(www.)?}, '').sub(%r{/$}, '')
    link_to label, url if url
  end

  def stock_peers
    (@stock.peers || []).map do |peer|
      @stock.symbol == peer ? nil : { symbol: peer, stock: XStocks::AR::Stock.find_by(symbol: peer) }
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
    positions = @positions.reject { |position| (position.market_value || 0).zero? }
    positions = positions.sort_by(&:market_value).reverse
    values = positions.map { |position| position.market_value.to_f }
    labels = positions.map { |position| @stocks_by_id[position.stock_id].symbol }
    [values, labels]
  end

  def sector_allocation
    sectors = {}
    positions = @positions.reject { |pos| (pos.market_value || 0).zero? }
    positions.each do |position|
      stock = @stocks_by_id[position.stock_id]
      sector = sectors[stock.sector] ||= { sector: stock.sector, value: 0, symbols: [] }
      sector[:value] += position.market_value
      sector[:symbols] << stock.symbol
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

  def meta_score_class(value)
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

  def country_flag_img_tag(country, options)
    size = options.delete(:size) || 64
    link = CountryFlag.new.link(country, size: size)
    tag(:img, { src: link }.merge(options)) if link
  end

  def up_down_tag(direction, css_class: nil)
    direction = Etl::Transform::Yahoo.new.direction(direction) if direction.is_a?(String)
    dir = { 1 => 'up', 0 => 'right', -1 => 'down' }[direction <=> 0]
    col = { 1 => 'success', 0 => 'muted', -1 => 'danger' }[direction <=> 0]
    content_tag(:i, class: "fas fa-caret-#{dir} text-#{col} #{css_class}") { '' }
  end

  def render_range(min, max, curr, change)
    curr_pct = inv_lerp(min, max, curr) * 100
    change_pct = inv_lerp(0, max - min, change) * 100

    progress1 = (change < 0) ? curr_pct + change_pct : curr_pct
    progress2 = (change < 0) ? -change_pct : change_pct
    progress2 = 2 if (progress2 < 2)
    css_class = (change < 0) ? 'bg-danger' : 'bg-success'

    progress = "<div class='progress'>
      <div class='progress-bar' role='progressbar' style='width: #{progress1}%; background-color: transparent;'></div>
      <div class='progress-bar #{css_class}' role='progressbar' style='width: #{progress2}%'></div>
      </div>"

    label = "<small>
      <span class='float-left'>#{number_to_currency(min)}</span>
      <span class='float-right'>#{number_to_currency(max)}</span>
      </small>"

    "<div class='price-range'>#{label}#{progress}</div>".html_safe
  end

  def inv_lerp(min, max, value)
    if min < max
      return 0 if value <= min
      return 1 if value >= max
    else
      return 0 if value >= min
      return 1 if value <= max
    end

    (value - min).to_f / (max - min)
  end
end

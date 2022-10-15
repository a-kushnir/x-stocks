# frozen_string_literal: true

# Helper methods for StocksController
module StocksHelper
  def link_to_website(url)
    label = url.sub(%r{^https?://(www.)?}, '').sub(%r{/$}, '')
    link_to label, url, class: 'text-blue-500 no-underline' if url
  end

  def stock_peers
    (@stock.peers || []).select(&:present?).map do |peer|
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
      'bmo' => t('stocks.next_earnings.before_market_open'),
      'amc' => t('stocks.next_earnings.after_market_close'),
      'dmh' => t('stocks.next_earnings.during_market_hours')
    }[value] || t('stocks.next_earnings.unknown')
  end

  def country_flag_img_tag(country, options)
    size = options.delete(:size) || 64
    link = CountryFlag.new.link(country, size: size)
    image_tag(link, options) if link
  end

  def up_down_tag(direction, size: '16*16')
    return unless direction

    direction = Etl::Transform::Yahoo.new.direction(direction) if direction.is_a?(String)
    icon = { 1 => 'svg/caret-up', 0 => 'svg/caret-right', -1 => 'svg/caret-down' }[direction <=> 0]
    color = { 1 => 'text-positive', 0 => 'text-neutral', -1 => 'text-negative' }[direction <=> 0]
    inline_svg(icon, size: size, class: color)
  end

  def render_range(min, max, curr, change)
    points = [curr, curr - change].sort
    progress1 = Math.inv_lerp(min, max, points[0]) * 100
    progress2 = (Math.inv_lerp(min, max, points[1]) * 100) - progress1
    progress2 = 2 if progress2 < 2 # Min width is 2%
    css_class = change.negative? ? 'negative' : 'positive'

    html = []
    html << '<div class="price-range" style="margin-top: 3px;">'
    html << "<div style='width: #{progress1.round}%;'></div>"
    html << "<div class='#{css_class}' style='width: #{progress2.round}%'></div>"
    html << '</div>'
    html << '<span class="text-xs">'
    html << "<span class='float-left'>#{number_to_currency(min, unit: '')}</span>"
    html << "<span class='float-right'>#{number_to_currency(max, unit: '')}</span>"
    html << '</span>'
    html.join.html_safe
  end
end

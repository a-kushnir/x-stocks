class StockQuote < ApplicationRecord

  belongs_to :stock

  def price_change
    return nil if current_price.nil? || prev_close_price.nil?
    current_price - prev_close_price
  end

  def price_change_pct
    return nil if price_change.nil?
    (price_change / prev_close_price * 100).round(2)
  end

end

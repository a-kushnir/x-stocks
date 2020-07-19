class Position < ApplicationRecord

  belongs_to :user
  belongs_to :stock, optional: true

  validates :user, presence: true
  validates :stock, presence: true, uniqueness: { scope: :user }
  validates :shares, numericality: true, allow_nil: true
  validates :average_price, numericality: true, allow_nil: true

  before_save :update_prices, :update_dividends

  def to_s
    stock&.to_s
  end

  def self.update_prices!(stock)
    model = where(stock: stock)
    model.update_all(market_price: stock.current_price)
    model.update_all('market_value = market_price * shares')
    model.update_all('gain_loss = market_value - total_cost')
    model.update_all('gain_loss_pct = gain_loss / total_cost * 100')
  end

  def self.day_change(user)
    p = Position.unscoped
        .select('SUM(positions.market_value) market_value, SUM(positions.shares * stocks.price_change) price_change')
        .joins('JOIN stocks ON positions.stock_id = stocks.id')
        .where(user: user).to_a.first
    { market_value: p.market_value, price_change: p.price_change, price_change_pct: p.price_change / p.market_value * 100 } rescue nil
  end

  def self.est_ann_income(user)
    Position.where(user: user).sum('est_annual_income')
  end

  def update_prices
    self.total_cost = average_price * shares rescue nil
    self.market_price = stock.current_price rescue nil
    self.market_value = market_price * shares rescue nil
    self.gain_loss = market_value - total_cost rescue nil
    self.gain_loss_pct = gain_loss / total_cost * 100 rescue nil
  end

  def self.update_dividends!(stock)
    model = where(stock: stock)
    model.update_all(est_annual_dividend: stock.est_annual_dividend)
    model.update_all('est_annual_income = est_annual_dividend * shares')
  end

  def update_dividends
    self.est_annual_dividend = stock.est_annual_dividend
    self.est_annual_income = est_annual_dividend * shares rescue nil
  end
end

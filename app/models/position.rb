class Position < ApplicationRecord

  belongs_to :user
  belongs_to :stock

  validates :user, presence: true
  validates :stock, presence: true, uniqueness: { scope: :user }

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

class Position < ApplicationRecord

  belongs_to :user
  belongs_to :stock

  validates :user, presence: true
  validates :stock, presence: true, uniqueness: { scope: :user }

  def to_s
    stock&.to_s
  end

  def self.update_prices!(stock)
    model = where(stock: stock)
    model.update_all(market_price: stock.current_price)
    model.update_all('market_value = shares * market_price')
  end

end

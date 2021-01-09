# frozen_string_literal: true

class Position < ApplicationRecord
  belongs_to :user
  belongs_to :stock, optional: true

  validates :user, presence: true
  validates :stock, presence: true, uniqueness: { scope: :user }
  validates :shares, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :average_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_save :remove_zero_numbers, :update_prices, :update_dividends

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
    { market_value: p.market_value || 0, price_change: p.price_change || 0, price_change_pct: begin
                                                                                                p.price_change / p.market_value * 100
                                                                                              rescue StandardError
                                                                                                0
                                                                                              end }
  end

  def self.market_value(user)
    Position.where(user: user).sum('market_value')
  end

  def self.est_ann_income(user)
    Position.where(user: user).sum('est_annual_income')
  end

  def update_prices
    self.total_cost = begin
                        average_price * shares
                      rescue StandardError
                        nil
                      end
    self.market_price = begin
                          stock.current_price
                        rescue StandardError
                          nil
                        end
    self.market_value = begin
                          market_price * shares
                        rescue StandardError
                          nil
                        end
    self.gain_loss = begin
                       market_value - total_cost
                     rescue StandardError
                       nil
                     end
    self.gain_loss_pct = begin
                           gain_loss / total_cost * 100
                         rescue StandardError
                           nil
                         end
  end

  def self.update_dividends!(stock)
    model = where(stock: stock)
    model.update_all(est_annual_dividend: stock.div_suspended? ? nil : stock.est_annual_dividend)
    model.update_all('est_annual_income = est_annual_dividend * shares')
  end

  def update_dividends
    self.est_annual_dividend = stock.div_suspended? ? nil : stock.est_annual_dividend
    self.est_annual_income = begin
                               est_annual_dividend * shares
                             rescue StandardError
                               nil
                             end
  end

  def remove_zero_numbers
    self.shares = nil if shares&.zero?
    self.average_price = nil if average_price&.zero?
  end
end

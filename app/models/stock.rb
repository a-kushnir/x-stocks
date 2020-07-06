class Stock < ApplicationRecord
  validates :symbol, presence: true, uniqueness: true

  before_validation :upcase_symbol

  def to_s
    symbol
  end

  private

  def upcase_symbol
    self.symbol = symbol.upcase
  end
end

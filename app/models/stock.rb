class Stock < ApplicationRecord

  has_one :company

  before_validation :upcase_symbol
  validates :symbol, presence: true, uniqueness: true

  def to_s
    symbol
  end

  private

  def upcase_symbol
    self.symbol = symbol.upcase
  end
end

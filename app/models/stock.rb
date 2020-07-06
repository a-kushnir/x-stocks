class Stock < ApplicationRecord
  validates :symbol, presence: true, uniqueness: true

  before_validation :upcase_symbol

  private

  def upcase_symbol
    self.symbol = symbol.upcase
  end
end

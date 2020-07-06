class Stock < ApplicationRecord
  validates :symbol, presence: true, uniqueness: true
end

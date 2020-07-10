class Tag < ApplicationRecord

  has_many :stocks_tags
  has_many :stocks, through: :stocks_tags

  validates :key, presence: true
  validates :name, presence: true, uniqueness: { scope: :key }

  def to_s
    name
  end

end

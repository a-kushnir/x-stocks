class Stock < ApplicationRecord

  belongs_to :exchange, optional: true
  has_many :stocks_tags, dependent: :destroy
  has_many :tags, through: :stocks_tags do
    def by_key(key)
      where(key: key)
    end
  end

  before_validation :upcase_symbol
  validates :symbol, presence: true, uniqueness: true

  def to_s
    if company_name.present?
      "#{company_name} (#{symbol})"
    else
      symbol
    end
  end

  def update_prices!
    self.price_change = (current_price - prev_close_price) rescue nil
    self.price_change_pct = (price_change / prev_close_price * 100) rescue nil
    ::Position.update_prices!(self)
    save!
  end

  private

  def upcase_symbol
    self.symbol = symbol.upcase
  end

end

class Stock < ApplicationRecord

  belongs_to :exchange, optional: true
  has_many :positions
  has_many :tags, dependent: :destroy do
    def by_key(key)
      where(key: key)
    end
  end

  default_scope { order(symbol: :asc) }

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

  def destroyable?
    !positions.exists?
  end

  private

  def upcase_symbol
    self.symbol = symbol.upcase
  end

end

class Stock < ApplicationRecord

  belongs_to :exchange, optional: true
  has_many :positions
  has_many :tags, dependent: :destroy do
    def by_key(key)
      where(key: key)
    end
  end

  default_scope { order(symbol: :asc) }
  scope :random, -> { unscoped.order('RANDOM()') }

  before_validation :upcase_symbol
  validates :symbol, presence: true, uniqueness: true

  before_save :update_metascore

  serialize :peers, JSON
  serialize :yahoo_rec_details, JSON
  serialize :finnhub_rec_details, JSON
  serialize :finnhub_price_target, JSON
  serialize :earnings, JSON
  serialize :dividend_details, JSON
  serialize :metascore_details, JSON

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
    self.est_annual_dividend_pct = est_annual_dividend / current_price * 100 rescue nil
    self.market_capitalization = outstanding_shares * current_price rescue nil
    ::Position.update_prices!(self)
    save!
  end

  def update_dividends!
    self.est_annual_dividend_pct = est_annual_dividend / current_price * 100 rescue nil
    ::Position.update_dividends!(self)
    save!
  end

  def update_metascore
    self.metascore, self.metascore_details = Metascore.new.calculate(self)
  end

  def destroyable?
    !positions.exists?
  end

  def index?
    issue_type == 'et'
  end

  private

  def upcase_symbol
    self.symbol = symbol.upcase
  end

end

# frozen_string_literal: true

# Stock Active Record Model
class Stock < ApplicationRecord
  DAYS_IN_YEAR = 365.25

  DIVIDEND_FREQUENCIES = {
    'annual' => 1,
    'semi-annual' => 2,
    'quarterly' => 4,
    'monthly' => 12
  }.freeze

  belongs_to :exchange, optional: true, class_name: 'XStocks::AR::Exchange'
  has_many :positions, class_name: 'XStocks::AR::Position'
  has_many :tags, dependent: :destroy, class_name: 'XStocks::AR::Tag' do
    def by_key(key)
      where(key: key)
    end
  end

  default_scope { order(symbol: :asc) }
  scope :random, -> { unscoped.order('RANDOM()') }

  before_validation :strip_symbol, :upcase_symbol
  validates :symbol, presence: true, uniqueness: true

  before_save :update_metascore

  serialize :peers, JSON
  serialize :yahoo_rec_details, JSON
  serialize :finnhub_rec_details, JSON
  serialize :finnhub_price_target, JSON
  serialize :earnings, JSON
  serialize :dividend_details, JSON
  serialize :next_earnings_details, JSON
  serialize :metascore_details, JSON

  def self.dividend_frequencies
    DIVIDEND_FREQUENCIES
  end

  def to_s
    if company_name.present?
      "#{company_name} (#{symbol})"
    else
      symbol
    end
  end

  def update_prices!
    self.price_change = begin
                          (current_price - prev_close_price)
                        rescue StandardError
                          nil
                        end
    self.price_change_pct = begin
                              (price_change / prev_close_price * 100)
                            rescue StandardError
                              nil
                            end
    self.est_annual_dividend_pct = begin
                                     est_annual_dividend / current_price * 100
                                   rescue StandardError
                                     nil
                                   end
    self.market_capitalization = begin
                                   outstanding_shares * current_price
                                 rescue StandardError
                                   nil
                                 end
    XStocks::Position.new.calculate_stock_prices(self)
    save!
  end

  def update_dividends!
    self.est_annual_dividend_pct = begin
                                     est_annual_dividend / current_price * 100
                                   rescue StandardError
                                     nil
                                   end
    XStocks::Position.new.calculate_stock_dividends(self)
    save!
  end

  def update_metascore
    self.metascore, self.metascore_details = MetaScore.new.calculate(self)
  end

  def destroyable?
    !positions.exists?
  end

  def index?
    issue_type == 'et'
  end

  def div_suspended?
    last_div = dividend_details&.last
    (dividend_amount || est_annual_dividend || dividend_frequency_num || dividend_growth_3y || dividend_growth_5y) &&
      (next_div_ex_date.nil? || begin
                                  next_div_ex_date.past? && (next_div_ex_date < (1.5 * DAYS_IN_YEAR / dividend_frequency_num).days.ago)
                                rescue StandardError
                                  true
                                end) &&
      begin
        last_div.nil? || (last_div['ex_date'] < (1.5 * DAYS_IN_YEAR / dividend_frequency_num).days.ago)
      rescue StandardError
        true
      end
  end

  def div_change_pct
    if div_suspended?
      -100
    else
      size = periodic_dividend_details.size
      last = periodic_dividend_details[size - 1]
      prev = periodic_dividend_details[size - 2]
      if last && prev
        begin
          100 * ((last['amount'] - prev['amount']) / prev['amount']).round(4)
        rescue StandardError
          0
        end
      end
    end
  end

  def periodic_dividend_details
    (dividend_details || []).select { |detail| DIVIDEND_FREQUENCIES[(detail['frequency'] || '').downcase] }
  end

  private

  def strip_symbol
    self.symbol = symbol.strip
  end

  def upcase_symbol
    self.symbol = symbol.upcase
  end
end

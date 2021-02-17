# frozen_string_literal: true

module XStocks
  module AR
    # Stock Active Record Model
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

      validates :symbol, presence: true, uniqueness: true

      serialize :peers, JSON
      serialize :yahoo_rec_details, JSON
      serialize :yahoo_price_target, JSON
      serialize :finnhub_rec_details, JSON
      serialize :finnhub_price_target, JSON
      serialize :earnings, JSON
      serialize :financials_yearly, JSON
      serialize :financials_quarterly, JSON
      serialize :dividend_details, JSON
      serialize :next_earnings_details, JSON
      serialize :metascore_details, JSON
    end
  end
end

# frozen_string_literal: true

module XStocks
  module AR
    # Stock Active Record Model
    class Stock < ApplicationRecord
      include Hashid::Rails

      belongs_to :exchange, optional: true
      has_many :dividends, dependent: :destroy
      has_many :positions
      has_many :tags, dependent: :destroy do
        def by_key(key)
          where(key: key)
        end
      end

      default_scope { order(symbol: :asc) }
      scope :random, -> { unscoped.order('RANDOM()') }

      validates :symbol, presence: true, uniqueness: true
      validates :yahoo_fair_price, numericality: { allow_nil: true, greater_than: 0 }

      serialize :peers, JSON
      serialize :yahoo_rec_details, JSON
      serialize :yahoo_price_target, JSON
      serialize :yahoo_short_outlook, JSON
      serialize :yahoo_medium_outlook, JSON
      serialize :yahoo_long_outlook, JSON
      serialize :finnhub_rec_details, JSON
      serialize :finnhub_price_target, JSON
      serialize :earnings, JSON
      serialize :financials_yearly, JSON
      serialize :financials_quarterly, JSON
      serialize :next_earnings_details, JSON
      serialize :metascore_details, JSON
      serialize :taxes, JSON

      # Used for dom_id, links, etc.
      def hashid
        symbol
      end
    end
  end
end

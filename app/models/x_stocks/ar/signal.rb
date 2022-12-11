# frozen_string_literal: true

module XStocks
  module AR
    # Financial Active Record Model
    class Signal < ApplicationRecord
      belongs_to :stock

      validates :timestamp, :detection_method, :value, :price, presence: true
      validates :value, inclusion: { in: %w(buy sell) }

      default_scope { order(timestamp: :desc) }

      scope :buy, -> { where(value: 'buy') }
      scope :sell, -> { where(value: 'sell') }

      def buy?
        value == 'buy'
      end

      def sell?
        value == 'buy'
      end
    end
  end
end

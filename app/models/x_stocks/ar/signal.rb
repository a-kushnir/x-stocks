# frozen_string_literal: true

module XStocks
  module AR
    # Financial Active Record Model
    class Signal < ApplicationRecord
      belongs_to :stock

      validates :timestamp, :detection_method, :value, :price, presence: true

      default_scope { order(timestamp: :desc) }
    end
  end
end

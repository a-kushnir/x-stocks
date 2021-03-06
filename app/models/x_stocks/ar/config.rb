# frozen_string_literal: true

module XStocks
  module AR
    # Config Active Record Model
    class Config < XStocks::AR::ApplicationRecord
      validates :key, presence: true, uniqueness: true
      serialize :value, JSON
    end
  end
end

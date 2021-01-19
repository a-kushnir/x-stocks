# frozen_string_literal: true

module XStocks
  module AR
    # Tag Active Record Model
    class Tag < ApplicationRecord
      belongs_to :stock

      validates :key, presence: true
      validates :name, presence: true, uniqueness: { scope: %i[key stock] }

      default_scope { order(name: :asc) }
    end
  end
end

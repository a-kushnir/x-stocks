# frozen_string_literal: true

module XStocks
  module AR
    # Position Active Record Model
    class Position < XStocks::AR::ApplicationRecord
      belongs_to :user
      belongs_to :stock, optional: true, touch: true

      validates :user, presence: true
      validates :stock, presence: true, uniqueness: { scope: :user }
      validates :shares, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
      validates :average_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
    end
  end
end

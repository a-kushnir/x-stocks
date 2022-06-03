# frozen_string_literal: true

module XStocks
  module AR
    # Watchlist Active Record Model
    class Watchlist < XStocks::AR::ApplicationRecord
      belongs_to :user

      validates :name, presence: true, uniqueness: { scope: :user_id }

      serialize :symbols, JSON
    end
  end
end

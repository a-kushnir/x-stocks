# frozen_string_literal: true

module XStocks
  module AR
    # Exchange Active Record Model
    class Exchange < XStocks::AR::ApplicationRecord
      validates :name, presence: true, uniqueness: true
      validates :code, presence: true, uniqueness: true
    end
  end
end

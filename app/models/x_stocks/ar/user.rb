# frozen_string_literal: true

module XStocks
  module AR
    # User Active Record Model
    class User < XStocks::AR::ApplicationRecord
      devise :database_authenticatable, :registerable,
             :recoverable, :rememberable, :validatable, :trackable

      serialize :favorites, JSON
      serialize :taxes, JSON
      validates_hash_values :taxes, numericality: { greater_than_or_equal_to: 0, less_than: 100, allow_blank: true }
    end
  end
end

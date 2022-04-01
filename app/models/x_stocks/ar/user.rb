# frozen_string_literal: true

module XStocks
  module AR
    # User Active Record Model
    class User < XStocks::AR::ApplicationRecord
      devise :database_authenticatable, :registerable,
             :recoverable, :rememberable, :validatable, :trackable

      serialize :favorites, JSON
    end
  end
end

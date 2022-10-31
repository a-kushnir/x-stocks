# frozen_string_literal: true

module XStocks
  module AR
    # Financial Active Record Model
    class Financial < ApplicationRecord
      belongs_to :stock

      validates :cik, :start_date, :end_date, :fiscal_year, :fiscal_period, presence: true

      default_scope { order(end_date: :desc) }
    end
  end
end

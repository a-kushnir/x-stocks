# frozen_string_literal: true

# Helper methods for DividendsController
module DividendsHelper
  def dividends_allocation
    positions = @positions.reject { |position| (position.est_annual_income || 0).zero? }
    positions = positions.sort_by(&:est_annual_income).reverse
    values = positions.map { |position| position.est_annual_income.to_f }
    labels = positions.map { |position| @stocks_by_id[position.stock_id].symbol }
    [values, labels]
  end
end

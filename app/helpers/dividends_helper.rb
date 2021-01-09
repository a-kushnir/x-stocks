# frozen_string_literal: true

module DividendsHelper
  def dividends_allocation
    positions = @positions.reject { |pos| (pos.est_annual_income || 0).zero? }
    positions = positions.sort_by(&:est_annual_income).reverse
    values = positions.map { |p| p.est_annual_income.to_f }
    labels = positions.map { |p| p.stock.symbol }
    [values, labels]
  end
end

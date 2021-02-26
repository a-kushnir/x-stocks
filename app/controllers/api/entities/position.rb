# frozen_string_literal: true

module API
  module Entities
    # Position Entity Definitions
    class Position < API::Entities::Base
      expose(:symbol, documentation: { required: true }) { |model, _| model.stock.symbol }
      expose(:exchange) { |model, _| model.stock.exchange.code }
      with_options(format_with: :float, documentation: { type: :float }) do
        expose :shares
        expose :average_price
        expose :total_cost
        expose :market_price
        expose :market_value
        expose :gain_loss
        expose :gain_loss_pct
        expose :est_annual_income, as: :est_annual_dividend
        expose(:diversity) do |model, options|
          (100 * model.market_value / options[:market_value]).round(2).to_f
        rescue StandardError
          nil
        end
      end
    end
  end
end

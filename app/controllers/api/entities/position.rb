module API
  module Entities
    class Position < API::Entities::Base

      expose(:symbol) { |model, _| model.stock.symbol }
      expose(:exchange) { |model, _| model.stock.exchange.code }
      with_options(format_with: :float) do
        expose :shares, documentation: { type: Float}
        expose :average_price, documentation: { type: Float}
        expose :total_cost, documentation: { type: Float}
        expose :market_price, documentation: { type: Float}
        expose :market_value, documentation: { type: Float}
        expose :gain_loss, documentation: { type: Float}
        expose :gain_loss_pct, documentation: { type: Float}
        expose :est_annual_income, as: :est_annual_dividend, documentation: { type: Float }
        expose(:diversity, documentation: { type: Float }) { |model, options| (100 * model.market_value / options[:market_value]).round(2).to_f rescue nil }
      end

    end
  end
end

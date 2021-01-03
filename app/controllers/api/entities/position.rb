module API
  module Entities
    class Position < API::Entities::Base

      with_options(if: {type: :details}) do
        expose(:symbol) { |model, _| model.stock.symbol }
        expose(:exchange) { |model, _| model.stock.exchange.code }
        with_options(format_with: :float) do
          expose :shares
          expose :average_price
          expose :total_cost
          expose :market_price
          expose :market_value
          expose :gain_loss
          expose :gain_loss_pct
          expose :est_annual_dividend
          expose :est_annual_income
          expose(:diversity) { |model, options| (100 * model.market_value / options[:market_value]).round(2).to_f rescue nil }
        end
      end

      with_options(if: {type: :summary}) do
        with_options(format_with: :float) do
          expose :total_cost
          expose :market_value
          expose :gain_loss
          expose :gain_loss_pct
          expose :est_annual_income
        end
      end

    end
  end
end

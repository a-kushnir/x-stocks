# frozen_string_literal: true

module API
  module Entities
    # Portfolio Entity Definitions
    class Portfolio < API::Entities::Base
      with_options(format_with: :float, documentation: { type: Float }) do
        expose :total_cost
        expose :market_value
        expose :gain_loss
        expose :gain_loss_pct
        expose :est_annual_income, as: :est_annual_dividend
      end
      expose :positions, using: API::Entities::Position, documentation: { is_array: true }
    end
  end
end

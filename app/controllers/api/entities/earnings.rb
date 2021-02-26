# frozen_string_literal: true

module API
  module Entities
    # Stock Earnings Entity Definitions
    class Earnings < API::Entities::Base
      expose :symbol, documentation: { required: true }
      expose(:exchange) { |model, _| model.exchange&.code }

      with_options(format_with: :float, documentation: { type: :float }) do
        expose :eps_ttm
        expose :eps_growth_3y
        expose :eps_growth_5y
        expose :pe_ratio_ttm
        expose :earnings, format_with: nil, documentation: { type: :object }
        expose :next_earnings_date, format_with: nil, documentation: { type: :string }
        expose :next_earnings_hour, format_with: nil, documentation: { type: :string }
        expose :next_earnings_est_eps
        expose :next_earnings_details, format_with: nil, documentation: { type: :object }
        expose :financials_yearly, format_with: nil, documentation: { type: :object }
        expose :financials_quarterly, format_with: nil, documentation: { type: :object }
      end
    end
  end
end

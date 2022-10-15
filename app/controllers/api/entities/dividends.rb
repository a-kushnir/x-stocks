# frozen_string_literal: true

module API
  module Entities
    # Stock Dividends Entity Definitions
    class Dividends < API::Entities::Base
      expose :symbol, documentation: { required: true }
      expose(:exchange) { |model, _| model.exchange&.code }

      with_options(format_with: :float, documentation: { type: :float }) do
        expose :div_suspended?, as: :suspended, format_with: :bool, documentation: { type: :boolean }
        expose :dividend_frequency, as: :frequency, format_with: nil, documentation: { type: :string }
        expose :dividend_frequency_num, as: :frequency_num
        expose :dividend_growth_3y, as: :growth_3y
        expose :dividend_growth_5y, as: :growth_5y
        expose :dividend_growth_years, as: :growth_years
        expose :next_div_ex_date, as: :next_ex_date, format_with: nil, documentation: { type: :string }
        expose :next_div_payment_date, as: :next_payment_date, format_with: nil, documentation: { type: :string }
        expose :next_div_amount, as: :next_amount
        expose :dividend_amount, as: :prev_amount
        expose :current_price
        expose :est_annual_dividend, as: :est_annual_amount
        expose :est_annual_dividend_pct, as: :est_annual_amount_pct
        expose :payout_ratio
        expose :dividend_rating, as: :safety
      end
    end
  end
end

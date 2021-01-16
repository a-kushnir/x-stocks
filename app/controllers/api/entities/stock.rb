# frozen_string_literal: true

module API
  module Entities
    # Stock Entity Definitions
    class Stock < API::Entities::Base
      expose :symbol
      expose(:exchange) { |model, _| model.exchange.code }

      with_options(if: { type: :company }) do
        expose :company_name
        expose :industry
        expose :website
        expose :description
        expose :ceo
        expose :security_name
        expose :issue_type
        expose :sector
        expose :primary_sic_code
        expose :employees
        expose :address
        expose :address2
        expose :state
        expose :city
        expose :zip
        expose :country
        expose :phone
        expose :ipo
        expose :logo
        expose :peers
        expose :outstanding_shares
        expose :market_capitalization
        expose :sp500, format_with: :bool
        expose :nasdaq100, format_with: :bool
        expose :dowjones, format_with: :bool
      end

      with_options(if: { type: :quote }) do
        with_options(format_with: :float) do
          expose :current_price
          expose :prev_close_price
          expose :open_price
          expose :price_change
          expose :price_change_pct
          expose :day_low_price
          expose :day_high_price
          expose :week_52_high
          expose :week_52_high_date, format_with: nil
          expose :week_52_low
          expose :week_52_low_date, format_with: nil
        end
      end

      with_options(if: { type: :recommendations }) do
        expose :yahoo_beta, format_with: :float
        expose :yahoo_rec, format_with: :float
        expose :yahoo_rec_details
        expose :yahoo_discount
        expose :finnhub_beta, format_with: :float
        expose :finnhub_price_target
        expose :finnhub_rec, format_with: :float
        expose :finnhub_rec_details
        expose :metascore
        expose :metascore_details
      end

      with_options(if: { type: :earnings }) do
        with_options(format_with: :float) do
          expose :eps_ttm
          expose :eps_growth_3y
          expose :eps_growth_5y
          expose :pe_ratio_ttm
          expose :earnings, format_with: nil
          expose :next_earnings_date, format_with: nil
          expose :next_earnings_hour, format_with: nil
          expose :next_earnings_est_eps
          expose :next_earnings_details, format_with: nil
        end
      end

      with_options(if: { type: :dividends }) do
        with_options(format_with: :float) do
          expose :dividend_frequency, as: :frequency, format_with: nil
          expose :dividend_frequency_num, as: :frequency_num
          expose :dividend_growth_3y, as: :growth_3y
          expose :dividend_growth_5y, as: :growth_5y
          expose :dividend_growth_years, as: :growth_years
          expose :div_suspended?, as: :suspended, format_with: :bool
          expose :next_div_ex_date, as: :next_ex_date, format_with: nil
          expose :next_div_payment_date, as: :next_payment_date, format_with: nil
          expose :next_div_amount, as: :next_amount
          expose :div_change_pct, as: :next_amount_change_pct
          expose :dividend_amount, as: :prev_amount
          expose :current_price
          expose :est_annual_dividend, as: :est_annual_amount
          expose :est_annual_dividend_pct, as: :est_annual_amount_pct
          expose :payout_ratio
          expose :dividend_rating, as: :safety
          expose :dividend_details, as: :details, format_with: lambda { |details|
            details.each { |detail| detail['amount'] = detail['amount'].round(6) }
          }
        end
      end
    end
  end
end

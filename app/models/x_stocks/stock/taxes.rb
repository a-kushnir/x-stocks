# frozen_string_literal: true

module XStocks
  class Stock
    # Contains Tax Information
    module Taxes
      TAXES = {
        foreign_tax: ['Foreign Tax', nil, 'svg/earth', 'tag tag-orange'],
        schedule_k1: ['Schedule K-1 (Form 1065)', 'https://www.irs.gov/forms-pubs/about-schedule-k-1-form-1065', 'svg/file-document-multiple-outline', 'tag tag-red'],
        ordinary_divs: ['Non-Qualified Dividend', 'https://www.investopedia.com/terms/t/taxbracket.asp', 'svg/cash-multiple', 'tag tag-red'],
        qualified_divs: ['Qualified Dividends', 'https://en.wikipedia.org/wiki/Qualified_dividend', 'svg/cash-multiple', 'tag tag-green']
      }.freeze

      def est_annual_dividend_taxed(user)
        stock_taxes = (ar_stock.taxes || [])
        user_taxes = (user.taxes || {})

        taxes = [:ordinary_divs, :qualified_divs].map do |tax_code|
          user_tax = user_taxes[tax_code.to_s].presence
          user_tax.to_f if stock_taxes.include?(tax_code.to_s) && user_tax
        end.compact
        return nil if taxes.blank?

        avg_taxes = taxes.sum / taxes.count # Tax weight isn't supported yet; If both tax forms are present, they are estimated to have equal weight
        ar_stock.est_annual_dividend * (1.0 - avg_taxes / 100)
      end

      def est_annual_dividend_taxed_pct(user)
        est_annual_dividend_taxed(user) / ar_stock.current_price * 100
      end
    end
  end
end

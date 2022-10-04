# frozen_string_literal: true

module XStocks
  class Stock
    # Contains Tax Information
    module Taxes
      TAXES = {
        foreign_tax: [nil, 'svg/earth', 'tag tag-orange'],
        schedule_k1: ['https://www.irs.gov/forms-pubs/about-schedule-k-1-form-1065', 'svg/file-document-multiple-outline', 'tag tag-red'],
        ordinary_divs: ['https://www.investopedia.com/terms/t/taxbracket.asp', 'svg/cash-multiple', 'tag tag-red'],
        qualified_divs: ['https://en.wikipedia.org/wiki/Qualified_dividend', 'svg/cash-multiple', 'tag tag-green']
      }.freeze

      def tax_rate(user)
        @tax_rate ||= begin
          stock_taxes = (ar_stock.taxes || [])
          user_taxes = (user.taxes || {})

          taxes = %i[ordinary_divs qualified_divs].map do |tax_code|
            user_tax = user_taxes[tax_code.to_s].presence
            user_tax.to_f if stock_taxes.include?(tax_code.to_s) && user_tax
          end.compact

          if taxes.present?
            avg_taxes = taxes.sum / taxes.count # Tax weight isn't supported yet; If both tax forms are present, they are estimated to have equal weight
            avg_taxes / 100
          end
        end
      end

      def after_tax_rate(user)
        tax_rate = tax_rate(user)
        tax_rate ? 1.0 - tax_rate : nil
      end

      def est_annual_dividend_taxed(user)
        after_tax_rate = after_tax_rate(user)
        after_tax_rate && ar_stock.est_annual_dividend ? ar_stock.est_annual_dividend * after_tax_rate : nil
      end

      def est_annual_dividend_taxed_pct(user)
        est_annual_dividend_taxed(user) / ar_stock.current_price * 100
      end
    end
  end
end

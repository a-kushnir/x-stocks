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
    end
  end
end

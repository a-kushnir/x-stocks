# frozen_string_literal: true

require 'x_stocks/dividends/dividend_type'
require 'x_stocks/dividends/frequency'

module XStocks
  module AR
    # Dividend Active Record Model
    class Dividend < ApplicationRecord
      belongs_to :stock

      validates :stock_id, :declaration_date, :ex_dividend_date, :record_date, :pay_date, :amount, presence: true
      validates :dividend_type, presence: true, inclusion: { in: XStocks::Dividends::DividendType::ALL }
      validates :frequency, presence: true, inclusion: { in: XStocks::Dividends::Frequency::ALL }
    end
  end
end

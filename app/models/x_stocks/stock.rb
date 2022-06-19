# frozen_string_literal: true

module XStocks
  # Stock Business Model
  class Stock
    extend XStocks::Stock::ARFinders
    include XStocks::Stock::ARUpdaters
    include XStocks::Stock::Calculator
    include XStocks::Stock::Dividends
    include XStocks::Stock::IssueType
    include XStocks::Stock::MetaScore
    include XStocks::Stock::Taxes

    def initialize(ar_stock)
      @ar_stock = ar_stock
    end

    def to_s
      if ar_stock.company_name.present?
        "#{ar_stock.company_name} (#{ar_stock.symbol})"
      else
        ar_stock.symbol
      end
    end

    private

    attr_reader :ar_stock

    delegate :hashid, to: :ar_stock
    XStocks::ARForwarder.delegate_methods(self, :ar_stock, XStocks::AR::Stock)
  end
end

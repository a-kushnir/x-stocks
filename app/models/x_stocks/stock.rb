# frozen_string_literal: true

module XStocks
  # Stock Business Model
  class Stock
    include XStocks::Stock::Calculator
    include XStocks::Stock::MetaScore
    include XStocks::Stock::Dividends

    def destroyable?(stock)
      !stock.positions.exists?
    end

    def save(stock)
      prepare_symbol(stock)
      calculate_meta_score(stock)
      calculate_stock_prices(stock)
      calculate_stock_dividends(stock)
      return unless stock.save

      position = XStocks::Position.new
      position.calculate_stock_prices(stock)
      position.calculate_stock_dividends(stock)
    end

    def to_s(stock)
      if stock.company_name.present?
        "#{stock.company_name} (#{stock.symbol})"
      else
        stock.symbol
      end
    end

    private

    def prepare_symbol(stock)
      stock.symbol = stock.symbol.strip.upcase
    end
  end
end

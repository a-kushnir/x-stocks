# frozen_string_literal: true

module XStocks
  # Stock Business Model
  class Stock
    include XStocks::Stock::Calculator
    include XStocks::Stock::MetaScore
    include XStocks::Stock::Dividends

    ISSUE_TYPES = {
      'ad' => 'ADR (American Depositary Receipt)',
      're' => 'REIT (Real Estate Investment Trust)',
      'ce' => 'CEF (Closed-End Fund)',
      'si' => 'Secondary Issue',
      'lp' => 'Limited Partnerships',
      'cs' => 'Common Stock',
      'et' => 'ETF (Exchange Traded Fund)',
      'wt' => 'Warrant',
      'oef' => 'OEF (Open-End Fund)',
      'cef' => 'CEF (Closed-End Fund)',
      'ps' => 'Preferred Stock',
      'ut' => 'Unit',
      'temp' => 'Temporary'
    }.freeze

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

    def common_stock?(stock)
      %w[cs].include?(stock.issue_type)
    end

    def issue_type(stock)
      ISSUE_TYPES.fetch(stock.issue_type, 'Unknown')
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

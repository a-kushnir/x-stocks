# frozen_string_literal: true

module Etl
  module Refresh
    # Extracts and transforms data from finance.yahoo.com
    class Yahoo < Base
      PAUSE = 1.0 # Limit up to 1 request per second

      def daily_all_stocks
        each_stock_with_message do |stock, message|
          yield message if block_given?
          daily_one_stock(stock)
          sleep(PAUSE)
        end

        yield completed_message if block_given?
      end

      def daily_one_stock(stock)
        json = Etl::Extract::Yahoo.new(loader).summary(stock.symbol)
        Etl::Transform::Yahoo.new.summary(stock, json)
      end

      def scan_url(url, &block)
        symbols = Etl::Extract::Yahoo.new(loader).stock_list_from_url(url)

        init_csv_file('scan_url_yahoo.csv') if symbols.any?
        scan_symbols(symbols, &block)
      end

      def scan_file(file)
        loader = Etl::Extract::DataLoader.new(logger)
        symbols = Etl::Extract::Yahoo.new(loader).stock_list_from_page(file)

        init_csv_file('scan_file_yahoo.csv') if symbols.any?
        scan_symbols(symbols)
      end

      private

      def scan_symbols(symbols)
        add_csv_file_row(%w[symbol exists company_name current_price est_annual_dividend est_annual_dividend_pct discount fair_price recommendation])
        each_symbol_with_message(symbols) do |symbol, message|
          scan_symbol(symbol)
          yield message if block_given?
          sleep(PAUSE)
        end
      end

      def scan_symbol(symbol)
        json = Etl::Extract::Yahoo.new(loader).summary(symbol)
        stock = OpenStruct.new(symbol: symbol)
        Etl::Transform::Yahoo.new.summary(stock, json)

        row = [
          symbol,
          XStocks::AR::Stock.where(symbol: symbol).exists? ? 'Yes' : nil,
          stock.company_name,
          stock.current_price,
          stock.est_annual_dividend,
          stock.current_price && stock.est_annual_dividend ? (stock.est_annual_dividend / stock.current_price * 100).round(2) : nil,
          stock.yahoo_discount.to_i,
          stock.yahoo_fair_price,
          stock.yahoo_rec.to_f
        ]
        add_csv_file_row(row)
      end
    end
  end
end

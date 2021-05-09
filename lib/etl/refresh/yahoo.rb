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
        loader = Etl::Extract::DataLoader.new(logger)
        json = Etl::Extract::Yahoo.new(loader).summary(stock.symbol)
        Etl::Transform::Yahoo.new.summary(stock, json)
      end

      def scan_url(url)
        loader = Etl::Extract::DataLoader.new(logger)
        symbols = Etl::Extract::Yahoo.new(loader).stock_list_from_url(url)

        logger.init_file('scan_url_yahoo.csv', 'text/csv') if symbols.any?
        scan_symbols(symbols, loader: loader, logger: logger)
      end

      def scan_file(file)
        loader = Etl::Extract::DataLoader.new(logger)
        symbols = Etl::Extract::Yahoo.new(loader).stock_list_from_page(file)

        logger.init_file('scan_file_yahoo.csv', 'text/csv') if symbols.any?
        scan_symbols(symbols, loader: loader, logger: logger)
      end

      private

      def scan_symbols(symbols, loader:, logger:)
        add_csv_file_row(%w[symbol exists company_name current_price est_annual_dividend est_annual_dividend_pct discount fair_price recommendation], logger: logger)
        each_symbol_with_message(symbols) do |symbol, message|
          scan_symbol(symbol, loader: loader, logger: logger)
          yield message if block_given?
          sleep(PAUSE)
        end
      end

      def scan_symbol(symbol, loader:, logger:)
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
        add_csv_file_row(row, logger: logger)
      end

      def add_csv_file_row(row, logger:)
        logger.append_file("#{row.map { |cell| "\"#{cell.to_s.gsub('"', '""')}\"" }.join(',')}\r\n")
      end
    end
  end
end

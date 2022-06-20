# frozen_string_literal: true

module Etl
  module Refresh
    # Base methods for extracting and transforming data
    class Base
      attr_reader :logger

      def initialize(logger)
        @logger = logger
      end

      def loader
        @loader ||= Etl::Extract::DataLoader.new(logger)
      end

      def stock_message(stock, percent: 0, index: 0, count: 1)
        {
          message: t('services.processing_record', record: stock.symbol, index: index + 1, count: count),
          percent: percent
        }
      end

      def each_symbol_with_message(symbols)
        symbols.each_with_index do |symbol, index|
          yield symbol, {
            message: t('services.processing_record', record: symbol, index: index + 1, count: symbols.size),
            percent: index * 100 / symbols.length
          }
        end
      end

      def each_stock_with_message
        stocks = XStocks::Stock.find_all_random
        stocks.each_with_index do |stock, index|
          yield stock, {
            message: t('services.processing_record', record: stock.symbol, index: index + 1, count: stocks.size),
            percent: index * 100 / stocks.length
          }
        end
      end

      def processing_message(percent)
        {
          message: t('services.processing'),
          percent: percent
        }
      end

      def completed_message
        {
          message: t('services.complete'),
          percent: 100
        }
      end

      def init_csv_file(file_name)
        logger.init_file(file_name, 'text/csv')
      end

      def add_csv_file_row(row)
        logger.append_file("#{row.map { |cell| "\"#{cell.to_s.gsub('"', '""')}\"" }.join(',')}\r\n")
      end

      delegate :t, to: I18n
    end
  end
end

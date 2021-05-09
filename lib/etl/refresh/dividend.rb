# frozen_string_literal: true

module Etl
  module Refresh
    # Extracts and transforms data from dividend.com
    class Dividend < Base
      PAUSE = 1.0 # Limit up to 1 request per second

      def weekly_all_stocks
        each_stock_with_message do |stock, message|
          yield message if block_given?
          weekly_one_stock(stock)
          sleep(PAUSE)
        end

        yield completed_message if block_given?
      end

      def weekly_one_stock(stock)
        return if stock.exchange.blank?

        loader = Etl::Extract::DataLoader.new(logger)
        json = Etl::Extract::Dividend.new(loader).data(stock)
        Etl::Transform::Dividend.new.data(stock, json)
      end
    end
  end
end

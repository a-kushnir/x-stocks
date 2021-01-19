# frozen_string_literal: true

module Etl
  module Refresh
    # Extracts and transforms data from dividend.com
    class Dividend < Base
      PAUSE = 1.0 # Limit up to 1 request per second

      def weekly_all_stocks?
        XStocks::Service.new[:weekly_dividend].runnable?(1.day)
      end

      def weekly_all_stocks!(force: false)
        XStocks::Service.new.lock(:weekly_dividend, force: force) do |logger|
          each_stock_with_message do |stock, message|
            yield message if block_given?
            weekly_one_stock!(stock, logger: logger)
            sleep(PAUSE)
          end
          yield completed_message if block_given?
        end
      end

      def weekly_all_stocks(&block)
        weekly_all_stocks!(&block) if weekly_all_stocks?
      end

      def weekly_one_stock!(stock, logger: nil)
        return if stock.exchange.blank?

        loader = Etl::Extract::DataLoader.new(logger)
        json = Etl::Extract::Dividend.new(loader).data(stock)
        Etl::Transform::Dividend.new.data(stock, json)
      end
    end
  end
end

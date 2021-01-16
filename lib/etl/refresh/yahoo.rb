# frozen_string_literal: true

module Etl
  module Refresh
    class Yahoo < Base
      PAUSE = 1.0 # Limit up to 1 request per second

      def daily_all_stocks?
        Service[:daily_yahoo].runnable?(1.day)
      end

      def daily_all_stocks!(force: false)
        Service.lock(:daily_yahoo, force: force) do |logger|
          each_stock_with_message do |stock, message|
            yield message if block_given?
            daily_one_stock!(stock, logger: logger)
            sleep(PAUSE)
          end
          yield completed_message if block_given?
        end
      end

      def daily_all_stocks(&block)
        daily_all_stocks!(&block) if daily_all_stocks?
      end

      def daily_one_stock!(stock, logger: nil)
        loader = Etl::Extract::DataLoader.new(logger)
        json = Etl::Extract::Yahoo.new(loader).summary(stock)
        Etl::Transform::Yahoo.new.summary(stock, json)
      end
    end
  end
end

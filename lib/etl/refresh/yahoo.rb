module Etl
  module Refresh
    class Yahoo < Base

      PAUSE = 1.0 # Limit up to 1 request per second

      def daily_all_stocks?
        Service[:daily_yahoo].runnable?(1.day)
      end

      def daily_all_stocks!(force: false, &block)
        Service.lock(:daily_yahoo, force: force) do |logger|
          each_stock_with_message do |stock, message|
            block.call message if block_given?
            daily_one_stock!(stock, logger)
            sleep(PAUSE)
          end
        end
      end

      def daily_all_stocks(&block)
        daily_all_stocks!(block) if daily_all_stocks?
      end

      def daily_one_stock!(stock, logger = nil)
        json = Etl::Extract::Yahoo.new(logger: logger).statistics(stock.symbol)
        Etl::Transform::Yahoo::new(logger).statistics(stock, json)
      end

    end
  end
end

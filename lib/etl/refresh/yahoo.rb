module Etl
  module Refresh
    class Yahoo

      PAUSE = 1.0 # Limit up to 1 request per second

      def daily_all_stocks?
        Service[:daily_yahoo].runnable?(1.day)
      end

      def daily_all_stocks!
        Service.lock(:daily_yahoo) do |logger|
          Stock.random.all.each do |stock|
            daily_one_stock!(stock, logger)
            sleep(PAUSE)
          end
        end
      end

      def daily_all_stocks
        daily_all_stocks! if daily_all_stocks?
      end

      def daily_one_stock!(stock, logger = nil)
        json = Etl::Extract::Yahoo.new(logger).statistics(stock.symbol)
        Etl::Transform::Yahoo::new(logger).statistics(stock, json)
      end

    end
  end
end

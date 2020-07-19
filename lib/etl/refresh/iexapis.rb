module Etl
  module Refresh
    class Iexapis

      PAUSE = 1.0 / 30 # Limit up to 30 requests per second

      def weekly_all_stocks?
        Service[:weekly_iexapis].runnable?(1.day)
      end

      def weekly_all_stocks!
        Service.lock(:weekly_iexapis) do |logger|
          Stock.random.all.each do |stock|
            weekly_one_stock!(stock, logger)
            sleep(PAUSE)
          end
        end
      end

      def weekly_all_stocks
        weekly_all_stocks! if weekly_all_stocks?
      end

      def weekly_one_stock!(stock, logger = nil, immediate: false)
        json = Etl::Extract::Iexapis.new(logger).dividends(stock.symbol)
        Etl::Transform::Iexapis::new(logger).dividends(stock, json)
        sleep(PAUSE) unless immediate

        json = Etl::Extract::Iexapis.new(logger).dividends_3m(stock.symbol)
        Etl::Transform::Iexapis::new(logger).dividends(stock, json)
        sleep(PAUSE) unless immediate

        json = Etl::Extract::Iexapis.new(logger).dividends_6m(stock.symbol)
        Etl::Transform::Iexapis::new(logger).dividends(stock, json)
      end

    end
  end
end

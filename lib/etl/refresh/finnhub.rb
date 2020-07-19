module Etl
  module Refresh
    class Finnhub

      PAUSE_SHORT = 1.0 / 10 # Limit up to 10 requests per second
      PAUSE_LONG = 1.0 / 1 # Limit up to 1 requests per second

      ##########
      # Hourly #

      def hourly_all_stocks?
        Service[:stock_prices]&.runnable?(1.hour)
      end

      def hourly_all_stocks!
        Service.lock(:stock_prices) do |logger|
          Stock.random.all.each do |stock|
            hourly_one_stock!(stock, logger)
            sleep(PAUSE_SHORT)
          end
        end
      end

      def hourly_all_stocks
        hourly_all_stocks! if hourly_all_stocks?
      end

      def hourly_one_stock!(stock, logger = nil)
        json = Etl::Extract::Finnhub.new(logger).quote(stock.symbol)
        Etl::Transform::Finnhub::new(logger).quote(stock, json) if json
      end

      #########
      # Daily #

      def daily_all_stocks?
        Service[:daily_finnhub]&.runnable?(1.day)
      end

      def daily_all_stocks!
        Service.lock(:daily_finnhub) do |logger|
          Stock.random.all.each do |stock|
            daily_one_stock!(stock, logger)
            sleep(PAUSE_LONG)
          end
        end
      end

      def daily_all_stocks
        daily_all_stocks! if daily_all_stocks?
      end

      def daily_one_stock!(stock, logger = nil)
        json = Etl::Extract::Finnhub.new(logger).recommendation(stock.symbol)
        Etl::Transform::Finnhub.new(logger).recommendation(stock, json) if json
        sleep(PAUSE_LONG)

        json = Etl::Extract::Finnhub.new(logger).price_target(stock.symbol)
        Etl::Transform::Finnhub.new(logger).price_target(stock, json) if json
        sleep(PAUSE_LONG)

        json = Etl::Extract::Finnhub.new(logger).earnings(stock.symbol)
        Etl::Transform::Finnhub.new(logger).earnings(stock, json) if json
        sleep(PAUSE_LONG)

        json = Etl::Extract::Finnhub.new(logger).metric(stock.symbol)
        Etl::Transform::Finnhub.new(logger).metric(stock, json) if json
      end

    end
  end
end

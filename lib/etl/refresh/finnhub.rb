module Etl
  module Refresh
    class Finnhub

      PAUSE_SHORT = 1.0 / 2 # Limit up to 2 requests per second
      PAUSE_LONG = 1.0 * 2 # Limit up to a request per 2 seconds

      ##########
      # Hourly #

      def hourly_all_stocks?
        Service[:stock_prices].runnable?(1.hour)
      end

      def hourly_all_stocks!(force: false)
        Service.lock(:stock_prices, force: force) do |logger|
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
        Service[:daily_finnhub].runnable?(1.day)
      end

      def daily_all_stocks!(force: false)
        Service.lock(:daily_finnhub, force: force) do |logger|
          Stock.random.all.each do |stock|
            daily_one_stock!(stock, logger)
            sleep(PAUSE_LONG)
          end
        end
      end

      def daily_all_stocks
        daily_all_stocks! if daily_all_stocks?
      end

      def daily_one_stock!(stock, logger = nil, immediate: false)
        json = Etl::Extract::Finnhub.new(logger).recommendation(stock.symbol)
        Etl::Transform::Finnhub.new(logger).recommendation(stock, json) if json
        sleep(PAUSE_LONG) unless immediate

        json = Etl::Extract::Finnhub.new(logger).price_target(stock.symbol)
        Etl::Transform::Finnhub.new(logger).price_target(stock, json) if json
        sleep(PAUSE_LONG) unless immediate

        json = Etl::Extract::Finnhub.new(logger).earnings(stock.symbol)
        Etl::Transform::Finnhub.new(logger).earnings(stock, json) if json
        sleep(PAUSE_LONG) unless immediate

        json = Etl::Extract::Finnhub.new(logger).metric(stock.symbol)
        Etl::Transform::Finnhub.new(logger).metric(stock, json) if json
      end

      ##########
      # Weekly #

      def weekly_all_stocks?
        Service[:weekly_finnhub].runnable?(1.day)
      end

      def weekly_all_stocks!(force: false)
        Service.lock(:weekly_finnhub, force: force) do |logger|
          earnings_calendar(logger)
        end
      end

      def weekly_all_stocks
        weekly_all_stocks! if weekly_all_stocks?
      end

      private

      def earnings_calendar(logger = nil, stock = nil)
        date = Date.today
        period = 1.week

        12.times do |index|
          sleep(PAUSE_LONG) if index != 0

          json = Etl::Extract::Finnhub.new(logger).earnings_calendar(date, date + period)
          Etl::Transform::Finnhub.new(logger).earnings_calendar(json, stock) if json

          date += period
        end
      end

    end
  end
end

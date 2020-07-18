module Etl
  module Refresh
    class Finnhub

      PAUSE = 1.0 / 10 # Limit up to 10 requests per second

      ##########
      # Hourly #

      def hourly_last_run_at
        Service[:stock_prices]
      end

      def hourly_all_stocks?
        updated_at = hourly_last_run_at
        updated_at.nil? || updated_at < 1.hour.ago
      end

      def hourly_all_stocks!
        Service.lock(:stock_prices) do |logger|
          Stock.all.each do |stock|
            hourly_one_stock!(stock, logger)
            sleep(PAUSE)
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

      def daily_last_run_at
        Service[:daily_finnhub]
      end

      def daily_all_stocks?
        updated_at = daily_last_run_at
        updated_at.nil? || updated_at < 1.day.ago
      end

      def daily_all_stocks!
        Service.lock(:daily_finnhub) do |logger|
          Stock.all.each do |stock|
            daily_one_stock!(stock, logger)
            sleep(PAUSE)
          end
        end
      end

      def daily_all_stocks
        daily_all_stocks! if daily_all_stocks?
      end

      def daily_one_stock!(stock, logger = nil)
        json = Etl::Extract::Finnhub.new(logger).recommendation(stock.symbol)
        Etl::Transform::Finnhub.new(logger).recommendation(stock, json) if json
        sleep(PAUSE)

        json = Etl::Extract::Finnhub.new(logger).price_target(stock.symbol)
        Etl::Transform::Finnhub.new(logger).price_target(stock, json) if json
        sleep(PAUSE)

        json = Etl::Extract::Finnhub.new(logger).earnings(stock.symbol)
        Etl::Transform::Finnhub.new(logger).earnings(stock, json) if json
        sleep(PAUSE)

        json = Etl::Extract::Finnhub.new(logger).metric(stock.symbol)
        Etl::Transform::Finnhub.new(logger).metric(stock, json) if json
      end

    end
  end
end

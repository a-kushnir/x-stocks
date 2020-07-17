module Etl
  module Refresh
    class Finnhub

      ##########
      # Hourly #

      def hourly_last_run_at
        DateTime.parse(Config[:stock_price_updated_at]) rescue nil
      end

      def hourly_all_stocks?
        updated_at = hourly_last_run_at
        updated_at.nil? || updated_at < 1.hour.ago
      end

      def hourly_all_stocks!
        Stock.all.each do |stock|
          hourly_one_stock!(stock)
          sleep(1.0/10) # Limit up to 10 requests per second
        end
        Config[:stock_price_updated_at] = DateTime.now
      end

      def hourly_all_stocks
        hourly_all_stocks! if hourly_all_stocks?
      end

      def hourly_one_stock!(stock)
        json = Etl::Extract::Finnhub.new.quote(stock.symbol)
        Etl::Transform::Finnhub::new.quote(stock, json)
      end

      #########
      # Daily #

      def daily_last_run_at
        DateTime.parse(Config[:daily_finnhub_updated_at]) rescue nil
      end

      def daily_all_stocks?
        updated_at = daily_last_run_at
        updated_at.nil? || updated_at < 1.day.ago
      end

      def daily_all_stocks!
        Stock.all.each do |stock|
          daily_one_stock!(stock)
          sleep(1.0/10) # Limit up to 10 requests per second
        end
        Config[:daily_finnhub_updated_at] = DateTime.now
      end

      def daily_all_stocks
        daily_all_stocks! if daily_all_stocks?
      end

      def daily_one_stock!(stock)
        json = Etl::Extract::Finnhub.new.recommendation(stock.symbol)
        Etl::Transform::Finnhub::new.recommendation(stock, json)

        json = Etl::Extract::Finnhub.new.price_target(stock.symbol)
        Etl::Transform::Finnhub::new.price_target(stock, json)

        json = Etl::Extract::Finnhub.new.earnings(stock.symbol)
        Etl::Transform::Finnhub::new.earnings(stock, json)

        json = Etl::Extract::Finnhub.new.metric(stock.symbol)
        Etl::Transform::Finnhub::new.metric(stock, json)
      end

    end
  end
end

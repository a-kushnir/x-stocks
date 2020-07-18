module Etl
  module Refresh
    class Iexapis

      PAUSE = 1.0 / 30 # Limit up to 30 requests per second

      def weekly_last_run_at
        Service[:weekly_iexapis]
      end

      def weekly_all_stocks?
        updated_at = weekly_last_run_at
        updated_at.nil? || updated_at < 1.day.ago
      end

      def weekly_all_stocks!
        Service.lock(:weekly_iexapis) do |logger|
          Stock.all.each do |stock|
            weekly_one_stock!(stock, logger)
            sleep(PAUSE)
          end
        end

        true
      end

      def weekly_all_stocks
        weekly_all_stocks! if weekly_all_stocks?
      end

      def weekly_one_stock!(stock, logger = nil)
        json = Etl::Extract::Iexapis.new(logger).dividends(stock.symbol)
        Etl::Transform::Iexapis::new(logger).dividends(stock, json)
        sleep(PAUSE)

        json = Etl::Extract::Iexapis.new(logger).dividends_3m(stock.symbol)
        Etl::Transform::Iexapis::new(logger).dividends(stock, json)
        sleep(PAUSE)

        json = Etl::Extract::Iexapis.new(logger).dividends_6m(stock.symbol)
        Etl::Transform::Iexapis::new(logger).dividends(stock, json)
      end

    end
  end
end

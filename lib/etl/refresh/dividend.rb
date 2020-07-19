module Etl
  module Refresh
    class Dividend

      PAUSE = 1.0 # Limit up to 1 request per second

      def weekly_all_stocks?
        Service[:weekly_dividend].runnable?(1.day)
      end

      def weekly_all_stocks!
        Service.lock(:weekly_dividend) do |logger|
          Stock.random.all.each do |stock|
            weekly_one_stock!(stock, logger)
            sleep(PAUSE)
          end
        end
      end

      def weekly_all_stocks
        weekly_all_stocks! if weekly_all_stocks?
      end

      def weekly_one_stock!(stock, logger = nil)
        return if stock.exchange.blank?
        json = Etl::Extract::Dividend.new(logger).data(stock)
        Etl::Transform::Dividend::new(logger).data(stock, json)
      end

    end
  end
end

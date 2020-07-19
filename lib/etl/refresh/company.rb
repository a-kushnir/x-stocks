module Etl
  module Refresh
    class Company

      def one_stock!(stock, logger = nil)
        json = Etl::Extract::Iexapis.new(logger).company(stock.symbol) rescue nil
        Etl::Transform::Iexapis::new(logger).company(stock, json) rescue nil

        json = Etl::Extract::Finnhub.new(logger).company(stock.symbol) rescue nil
        Etl::Transform::Finnhub::new(logger).company(stock, json) rescue nil

        json = Etl::Extract::Finnhub.new(logger).peers(stock.symbol) rescue nil
        Etl::Transform::Finnhub::new(logger).peers(stock, json) rescue nil

        Etl::Refresh::Finnhub.new.hourly_one_stock!(stock) rescue nil
        Etl::Refresh::Yahoo.new.daily_one_stock!(stock) rescue nil
        Etl::Refresh::Finnhub.new.daily_one_stock!(stock) rescue nil
        Etl::Refresh::Iexapis.new.weekly_one_stock!(stock) rescue nil
        Etl::Refresh::Dividend.new.weekly_one_stock!(stock) rescue nil
      end

    end
  end
end

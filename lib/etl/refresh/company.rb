module Etl
  module Refresh
    class Company

      def one_stock!(stock)
        json = Etl::Extract::Iexapis.new.company(stock.symbol) rescue nil
        Etl::Transform::Iexapis::new.company(stock, json) rescue nil

        json = Etl::Extract::Finnhub.new.company(stock.symbol) rescue nil
        Etl::Transform::Finnhub::new.company(stock, json) rescue nil

        json = Etl::Extract::Finnhub.new.peers(stock.symbol) rescue nil
        Etl::Transform::Finnhub::new.peers(stock, json) rescue nil

        Etl::Refresh::Finnhub.new.hourly_one_stock!(stock) rescue nil
        Etl::Refresh::Yahoo.new.daily_one_stock!(stock) rescue nil
        Etl::Refresh::Finnhub.new.daily_one_stock!(stock) rescue nil
        Etl::Refresh::Iexapis.new.weekly_one_stock!(stock) rescue nil
      end

    end
  end
end

module Etl
  module Refresh
    class Company

      def one_stock!(stock, logger = nil)
        iexapis_ts = TokenStore.new(Etl::Extract::Iexapis::TOKEN_KEY)
        finnhub_ts = TokenStore.new(Etl::Extract::Finnhub::TOKEN_KEY)

        json = Etl::Extract::Iexapis.new(token: iexapis_ts, logger: logger).company(stock.symbol) rescue nil
        Etl::Transform::Iexapis::new(logger).company(stock, json) rescue nil

        json = Etl::Extract::Finnhub.new(token: finnhub_ts, logger: logger).company(stock.symbol) rescue nil
        Etl::Transform::Finnhub::new(logger).company(stock, json) rescue nil

        json = Etl::Extract::Finnhub.new(token: finnhub_ts,logger: logger).peers(stock.symbol) rescue nil
        Etl::Transform::Finnhub::new(logger).peers(stock, json) rescue nil

        Etl::Refresh::Finnhub.new.hourly_one_stock!(stock, finnhub_ts) rescue nil
        Etl::Refresh::Yahoo.new.daily_one_stock!(stock) rescue nil
        Etl::Refresh::Finnhub.new.daily_one_stock!(stock, finnhub_ts, immediate: true) rescue nil
        Etl::Refresh::Iexapis.new.weekly_one_stock!(stock, iexapis_ts, nil, immediate: true) rescue nil
        Etl::Refresh::Dividend.new.weekly_one_stock!(stock) rescue nil

        Etl::Refresh::Slickcharts.new.all_stocks! rescue nil
        Etl::Refresh::Finnhub.new.weekly_all_stocks! rescue nil
      end

    end
  end
end

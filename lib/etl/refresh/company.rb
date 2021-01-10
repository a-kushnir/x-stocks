# frozen_string_literal: true

module Etl
  module Refresh
    class Company
      def one_stock!(stock, logger: nil)
        iexapis_ts = TokenStore.new(Etl::Extract::Iexapis::TOKEN_KEY)
        finnhub_ts = TokenStore.new(Etl::Extract::Finnhub::TOKEN_KEY)
        data_loader = Etl::Extract::DataLoader.new(logger)

        iexapis_ts.try_token do |token|
          json = Etl::Extract::Iexapis.new(data_loader, token).company(stock)
          Etl::Transform::Iexapis.new(logger).company(stock, json)
        end

        finnhub_ts.try_token do |token|
          json = Etl::Extract::Finnhub.new(data_loader, token).company(stock)
          Etl::Transform::Finnhub.new(logger).company(stock, json)
        end

        finnhub_ts.try_token do |token|
          json = Etl::Extract::Finnhub.new(data_loader, token).peers(stock)
          Etl::Transform::Finnhub.new(logger).peers(stock, json)
        end

        safe_exec { Etl::Refresh::Finnhub.new.hourly_one_stock!(stock, token_store: finnhub_ts, logger: logger) }
        safe_exec { Etl::Refresh::Yahoo.new.daily_one_stock!(stock, logger: logger) }
        safe_exec { Etl::Refresh::Finnhub.new.daily_one_stock!(stock, token_store: finnhub_ts, logger: logger, immediate: true) }
        safe_exec { Etl::Refresh::Iexapis.new.weekly_one_stock!(stock, token_store: iexapis_ts, logger: logger, immediate: true) }
        safe_exec { Etl::Refresh::Dividend.new.weekly_one_stock!(stock, logger: logger) }
        safe_exec { Etl::Refresh::Slickcharts.new.all_stocks! }
        safe_exec { Etl::Refresh::Finnhub.new.weekly_all_stocks! }
      end

      def safe_exec
        yield
      rescue Exception
        nil
      end
    end
  end
end

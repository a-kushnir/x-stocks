# frozen_string_literal: true

module Etl
  module Refresh
    # Extracts and transforms company data from multiple sources
    class Company < Base
      def one_stock!(stock, logger: nil)
        iexapis_ts = Etl::Extract::TokenStore.new(Etl::Extract::Iexapis::TOKEN_KEY)
        finnhub_ts = Etl::Extract::TokenStore.new(Etl::Extract::Finnhub::TOKEN_KEY)
        data_loader = Etl::Extract::DataLoader.new(logger)

        yield message('Loading company information [IEX Cloud]', 0) if block_given?
        safe_exec do
          iexapis_ts.try_token do |token|
            json = Etl::Extract::Iexapis.new(data_loader, token).company(stock)
            Etl::Transform::Iexapis.new.company(stock, json)
          end
        end

        yield message('Loading company information [Finnhub]', 5) if block_given?
        safe_exec do
          finnhub_ts.try_token do |token|
            json = Etl::Extract::Finnhub.new(data_loader, token).company(stock)
            Etl::Transform::Finnhub.new.company(stock, json)
          end
        end

        yield message('Loading company peers [Finnhub]', 10) if block_given?
        safe_exec do
          finnhub_ts.try_token do |token|
            json = Etl::Extract::Finnhub.new(data_loader, token).peers(stock)
            Etl::Transform::Finnhub.new.peers(stock, json)
          end
        end

        yield message('Update stock prices [Finnhub]', 15) if block_given?
        safe_exec { Etl::Refresh::Finnhub.new.hourly_one_stock!(stock, token_store: finnhub_ts, logger: logger) }

        yield message('Update stock information [Finnhub]', 20) if block_given?
        safe_exec { Etl::Refresh::Finnhub.new.daily_one_stock!(stock, token_store: finnhub_ts, logger: logger, immediate: true) }

        yield message('Update stock information [Yahoo]', 40) if block_given?
        safe_exec { Etl::Refresh::Yahoo.new.daily_one_stock!(stock, logger: logger) }

        yield message('Update stock dividends [IEX Cloud]', 60) if block_given?
        safe_exec { Etl::Refresh::Iexapis.new.weekly_one_stock!(stock, token_store: iexapis_ts, logger: logger, immediate: true) }

        yield message('Update stock dividends [Dividend.com]', 70) if block_given?
        safe_exec { Etl::Refresh::Dividend.new.weekly_one_stock!(stock, logger: logger) }

        yield message('Update upcoming earnings [Finnhub]', 75) if block_given?
        safe_exec { Etl::Refresh::Finnhub.new.weekly_all_stocks! }

        yield message('S&P 500, Nasdaq 100 and Dow Jones [SlickCharts]', 95) if block_given?
        safe_exec { Etl::Refresh::SlickCharts.new.all_stocks! }

        yield completed_message if block_given?
      end

      private

      def message(message, percent)
        { message: message, percent: percent }
      end

      def safe_exec
        yield
      rescue Exception
        nil
      end
    end
  end
end

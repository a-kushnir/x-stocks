# frozen_string_literal: true

module Etl
  module Refresh
    class Company
      def one_stock!(stock, logger: nil)
        iexapis_ts = TokenStore.new(Etl::Extract::Iexapis::TOKEN_KEY)
        finnhub_ts = TokenStore.new(Etl::Extract::Finnhub::TOKEN_KEY)

        iexapis_ts.try_token do |token|
          json = begin
                   Etl::Extract::Iexapis.new(token: token, logger: logger).company(stock.symbol)
                 rescue StandardError
                   nil
                 end
          begin
            Etl::Transform::Iexapis.new(logger).company(stock, json)
          rescue StandardError
            nil
          end
        end

        finnhub_ts.try_token do |token|
          json = begin
                   Etl::Extract::Finnhub.new(token: token, logger: logger).company(stock.symbol)
                 rescue StandardError
                   nil
                 end
          begin
            Etl::Transform::Finnhub.new(logger).company(stock, json)
          rescue StandardError
            nil
          end
        end

        finnhub_ts.try_token do |token|
          json = begin
                   Etl::Extract::Finnhub.new(token: token, logger: logger).peers(stock.symbol)
                 rescue StandardError
                   nil
                 end
          begin
            Etl::Transform::Finnhub.new(logger).peers(stock, json)
          rescue StandardError
            nil
          end
        end

        begin
          Etl::Refresh::Finnhub.new.hourly_one_stock!(stock, token_store: finnhub_ts, logger: logger)
        rescue StandardError
          nil
        end
        begin
          Etl::Refresh::Yahoo.new.daily_one_stock!(stock, logger: logger)
        rescue StandardError
          nil
        end
        begin
          Etl::Refresh::Finnhub.new.daily_one_stock!(stock, token_store: finnhub_ts, logger: logger, immediate: true)
        rescue StandardError
          nil
        end
        begin
          Etl::Refresh::Iexapis.new.weekly_one_stock!(stock, token_store: iexapis_ts, logger: logger, immediate: true)
        rescue StandardError
          nil
        end
        begin
          Etl::Refresh::Dividend.new.weekly_one_stock!(stock, logger: logger)
        rescue StandardError
          nil
        end

        begin
          Etl::Refresh::Slickcharts.new.all_stocks!
        rescue StandardError
          nil
        end
        begin
          Etl::Refresh::Finnhub.new.weekly_all_stocks!
        rescue StandardError
          nil
        end
      end
    end
  end
end

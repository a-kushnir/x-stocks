# frozen_string_literal: true

module Etl
  module Refresh
    # Extracts and transforms data from finnhub.io
    class Finnhub < Base
      PAUSE_SHORT = 1.0 / 10  # Limit up to 10 requests per second
      PAUSE_LONG = 1.0 / 3    # Limit up to 3 requests per second

      ##########
      # Hourly #

      def hourly_all_stocks
        token_store = Etl::Extract::TokenStore.new(Etl::Extract::Finnhub::TOKEN_KEY, logger)

        each_stock_with_message do |stock, message|
          yield message if block_given?
          hourly_one_stock(stock, token_store: token_store)
          sleep(PAUSE_SHORT)
        end

        yield completed_message if block_given?
      end

      def hourly_one_stock(stock, token_store: nil)
        token_store ||= Etl::Extract::TokenStore.new(Etl::Extract::Finnhub::TOKEN_KEY, logger)
        data_loader = Etl::Extract::DataLoader.new(logger)

        token_store.try_token do |token|
          json = Etl::Extract::Finnhub.new(data_loader, token).quote(stock)
          Etl::Transform::Finnhub.new.quote(stock, json) if json
        end
      end

      #########
      # Daily #

      def daily_all_stocks
        token_store = Etl::Extract::TokenStore.new(Etl::Extract::Finnhub::TOKEN_KEY, logger)

        each_stock_with_message do |stock, message|
          yield message if block_given?
          daily_one_stock(stock, token_store: token_store)
          sleep(PAUSE_LONG)
        end

        yield completed_message if block_given?
      end

      def daily_one_stock(stock, token_store: nil, immediate: false)
        token_store ||= Etl::Extract::TokenStore.new(Etl::Extract::Finnhub::TOKEN_KEY, logger)
        data_loader = Etl::Extract::DataLoader.new(logger)

        token_store.try_token do |token|
          json = Etl::Extract::Finnhub.new(data_loader, token).recommendation(stock)
          Etl::Transform::Finnhub.new.recommendation(stock, json) if json
          sleep(PAUSE_LONG) unless immediate
        end

        token_store.try_token do |token|
          json = Etl::Extract::Finnhub.new(data_loader, token).metric(stock)
          Etl::Transform::Finnhub.new.metric(stock, json) if json
        end
      end

      def company_all_stocks
        token_store = Etl::Extract::TokenStore.new(Etl::Extract::Finnhub::TOKEN_KEY, logger)
        data_loader = Etl::Extract::DataLoader.new(logger)

        each_stock_with_message do |stock, message|
          yield message if block_given?
          token_store.try_token do |token|
            json = Etl::Extract::Finnhub.new(data_loader, token).company(stock)
            Etl::Transform::Finnhub.new.company(stock, json) if json
          end
          sleep(PAUSE_SHORT)
        end

        yield completed_message if block_given?
      end

      private

      def safe_exec
        yield
      rescue Exception
        nil
      end
    end
  end
end

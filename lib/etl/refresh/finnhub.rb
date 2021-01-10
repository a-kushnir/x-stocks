# frozen_string_literal: true

module Etl
  module Refresh
    class Finnhub < Base
      PAUSE_SHORT = 1.0 / 10  # Limit up to 10 requests per second
      PAUSE_LONG = 1.0 / 3    # Limit up to 3 requests per second

      ##########
      # Hourly #

      def hourly_all_stocks?
        Service[:stock_prices].runnable?(1.hour)
      end

      def hourly_all_stocks!(force: false, &block)
        Service.lock(:stock_prices, force: force) do |logger|
          token_store = TokenStore.new(Etl::Extract::Finnhub::TOKEN_KEY, logger)
          each_stock_with_message do |stock, message|
            block.call message if block_given?
            hourly_one_stock!(stock, token_store: token_store, logger: logger)
            sleep(PAUSE_SHORT)
          end
          block.call completed_message if block_given?
        end
      end

      def hourly_all_stocks(&block)
        hourly_all_stocks!(&block) if hourly_all_stocks?
      end

      def hourly_one_stock!(stock, token_store: nil, logger: nil)
        token_store ||= TokenStore.new(Etl::Extract::Finnhub::TOKEN_KEY, logger)
        data_loader = Etl::Extract::DataLoader.new(logger)

        token_store.try_token do |token|
          json = Etl::Extract::Finnhub.new(data_loader, token).quote(stock)
          Etl::Transform::Finnhub.new(logger).quote(stock, json) if json
        end
      end

      #########
      # Daily #

      def daily_all_stocks?
        Service[:daily_finnhub].runnable?(1.day)
      end

      def daily_all_stocks!(force: false, &block)
        Service.lock(:daily_finnhub, force: force) do |logger|
          token_store = TokenStore.new(Etl::Extract::Finnhub::TOKEN_KEY, logger)
          each_stock_with_message do |stock, message|
            block.call message if block_given?
            daily_one_stock!(stock, token_store: token_store, logger: logger)
            sleep(PAUSE_LONG)
          end
          block.call completed_message if block_given?
        end
      end

      def daily_all_stocks(&block)
        daily_all_stocks!(&block) if daily_all_stocks?
      end

      def daily_one_stock!(stock, token_store: nil, logger: nil, immediate: false)
        token_store ||= TokenStore.new(Etl::Extract::Finnhub::TOKEN_KEY, logger)
        data_loader = Etl::Extract::DataLoader.new(logger)

        token_store.try_token do |token|
          json = Etl::Extract::Finnhub.new(data_loader, token).recommendation(stock)
          Etl::Transform::Finnhub.new(logger).recommendation(stock, json) if json
          sleep(PAUSE_LONG) unless immediate
        end

        token_store.try_token do |token|
          json = Etl::Extract::Finnhub.new(data_loader, token).price_target(stock)
          Etl::Transform::Finnhub.new(logger).price_target(stock, json) if json
          sleep(PAUSE_LONG) unless immediate
        end

        token_store.try_token do |token|
          json = Etl::Extract::Finnhub.new(data_loader, token).earnings(stock)
          Etl::Transform::Finnhub.new(logger).earnings(stock, json) if json
          sleep(PAUSE_LONG) unless immediate
        end

        token_store.try_token do |token|
          json = Etl::Extract::Finnhub.new(data_loader, token).metric(stock)
          Etl::Transform::Finnhub.new(logger).metric(stock, json) if json
        end
      end

      ##########
      # Weekly #

      def weekly_all_stocks?
        Service[:weekly_finnhub].runnable?(1.day)
      end

      def weekly_all_stocks!(force: false)
        Service.lock(:weekly_finnhub, force: force) do |logger|
          token_store = TokenStore.new(Etl::Extract::Finnhub::TOKEN_KEY, logger)
          earnings_calendar(token_store, logger: logger)
        end
      end

      def weekly_all_stocks
        weekly_all_stocks! if weekly_all_stocks?
      end

      private

      def earnings_calendar(token_store, logger: nil, stock: nil)
        date = Date.today
        period = 1.week
        data_loader = Etl::Extract::DataLoader.new(logger)

        12.times do |index|
          sleep(PAUSE_LONG) if index != 0

          token_store.try_token do |token|
            safe_exec do
              json = Etl::Extract::Finnhub.new(data_loader, token).earnings_calendar(date, date + period)
              Etl::Transform::Finnhub.new(logger).earnings_calendar(json, stock)
            end
          end

          date += period
        end
      end

      def safe_exec
        yield
      rescue Exception
        nil
      end
    end
  end
end

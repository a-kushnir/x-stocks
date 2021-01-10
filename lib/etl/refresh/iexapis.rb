# frozen_string_literal: true

module Etl
  module Refresh
    class Iexapis < Base
      PAUSE = 1.0 / 30 # Limit up to 30 requests per second

      def weekly_all_stocks?
        Service[:weekly_iexapis].runnable?(1.day)
      end

      def weekly_all_stocks!(force: false, &block)
        Service.lock(:weekly_iexapis, force: force) do |logger|
          token_store = TokenStore.new(Etl::Extract::Iexapis::TOKEN_KEY, logger)
          each_stock_with_message do |stock, message|
            block.call message if block_given?
            weekly_one_stock!(stock, token_store: token_store, logger: logger)
            sleep(PAUSE)
          end
          block.call completed_message if block_given?
        end
      end

      def weekly_all_stocks(&block)
        weekly_all_stocks!(&block) if weekly_all_stocks?
      end

      def weekly_one_stock!(stock, token_store: nil, logger: nil, immediate: false)
        token_store ||= TokenStore.new(Etl::Extract::Iexapis::TOKEN_KEY, logger)
        data_loader = Etl::Extract::DataLoader.new(logger)

        token_store.try_token do |token|
          json = Etl::Extract::Iexapis.new(data_loader, token).dividends_next(stock)
          Etl::Transform::Iexapis.new(logger).dividends(stock, json)
          Etl::Transform::Iexapis.new(logger).next_dividend(stock, json)
          sleep(PAUSE) unless immediate
        end

        token_store.try_token do |token|
          json = Etl::Extract::Iexapis.new(data_loader, token).dividends(stock)
          Etl::Transform::Iexapis.new(logger).dividends(stock, json)
          sleep(PAUSE) unless immediate
        end

        return if !immediate && stock.dividend_details.present?

        token_store.try_token do |token|
          json = Etl::Extract::Iexapis.new(data_loader, token).dividends_1m(stock)
          Etl::Transform::Iexapis.new(logger).dividends(stock, json)
          sleep(PAUSE) unless immediate
        end

        token_store.try_token do |token|
          json = Etl::Extract::Iexapis.new(data_loader, token).dividends_3m(stock)
          Etl::Transform::Iexapis.new(logger).dividends(stock, json)
          sleep(PAUSE) unless immediate
        end

        token_store.try_token do |token|
          json = Etl::Extract::Iexapis.new(data_loader, token).dividends_6m(stock)
          Etl::Transform::Iexapis.new(logger).dividends(stock, json)
        end
      end
    end
  end
end

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
        
        token_store.try_token do |token|
          json = Etl::Extract::Iexapis.new(token: token, logger: logger).dividends_next(stock.symbol)
          Etl::Transform::Iexapis::new(logger).dividends(stock, json)
          Etl::Transform::Iexapis::new(logger).next_dividend(stock, json)
          sleep(PAUSE) unless immediate
        end

        token_store.try_token do |token|
          json = Etl::Extract::Iexapis.new(token: token, logger: logger).dividends(stock.symbol)
          Etl::Transform::Iexapis::new(logger).dividends(stock, json)
          sleep(PAUSE) unless immediate
        end

        token_store.try_token do |token|
          json = Etl::Extract::Iexapis.new(token: token, logger: logger).dividends_1m(stock.symbol)
          Etl::Transform::Iexapis::new(logger).dividends(stock, json)
          sleep(PAUSE) unless immediate
        end

        token_store.try_token do |token|
          json = Etl::Extract::Iexapis.new(token: token, logger: logger).dividends_3m(stock.symbol)
          Etl::Transform::Iexapis::new(logger).dividends(stock, json)
          sleep(PAUSE) unless immediate
        end

        token_store.try_token do |token|
          json = Etl::Extract::Iexapis.new(token: token, logger: logger).dividends_6m(stock.symbol)
          Etl::Transform::Iexapis::new(logger).dividends(stock, json)
        end
      end

    end
  end
end

# frozen_string_literal: true

module Etl
  module Refresh
    # Extracts and transforms data from polygon.io
    class Polygon < Base
      PAUSE = 60.0 / 10 # Limit up to 10 requests per minute

      def weekly_all_stocks
        token_store = Etl::Extract::TokenStore.new(Etl::Extract::Polygon::TOKEN_KEY, logger)

        each_stock_with_message do |stock, message|
          yield message if block_given?
          weekly_one_stock(stock, token_store: token_store)

          sleep(PAUSE)
        end

        yield completed_message if block_given?
      end

      def weekly_one_stock(stock, token_store: nil, immediate: false)
        token_store ||= Etl::Extract::TokenStore.new(Etl::Extract::Polygon::TOKEN_KEY, logger)
        data_loader = Etl::Extract::DataLoader.new(logger)

        token_store.try_token do |token|
          json = Etl::Extract::Polygon.new(data_loader, token).dividends(stock)
          Etl::Transform::Polygon.new.dividends(stock, json)
          sleep(PAUSE) unless immediate
        end
      end
    end
  end
end

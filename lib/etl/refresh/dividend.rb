# frozen_string_literal: true

module Etl
  module Refresh
    class Dividend < Base
      PAUSE = 1.0 # Limit up to 1 request per second

      def weekly_all_stocks?
        Service[:weekly_dividend].runnable?(1.day)
      end

      def weekly_all_stocks!(force: false, &block)
        Service.lock(:weekly_dividend, force: force) do |logger|
          each_stock_with_message do |stock, message|
            block.call message if block_given?
            weekly_one_stock!(stock, logger: logger)
            sleep(PAUSE)
          end
          block.call completed_message if block_given?
        end
      end

      def weekly_all_stocks(&block)
        weekly_all_stocks!(&block) if weekly_all_stocks?
      end

      def weekly_one_stock!(stock, logger: nil)
        return if stock.exchange.blank?

        json = Etl::Extract::Dividend.new(logger: logger).data(stock)
        Etl::Transform::Dividend.new(logger).data(stock, json)
      end
    end
  end
end

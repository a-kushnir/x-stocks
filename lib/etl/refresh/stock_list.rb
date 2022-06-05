# frozen_string_literal: true

module Etl
  module Refresh
    # Extracts and transforms data for stock list
    class StockList
      def update(stocks, logger)
        progress_bar = ProgressBar.new
        progress_bar.loop(stocks) do |node|
          stock = node.object
          yield stock, node.percent

          node.steps do |steps|
            steps.step(weight: 3) do |step|
              Etl::Refresh::Finnhub.new(logger).daily_one_stock(stock)
              yield stock, step.percent
            end

            steps.step(weight: 2) do |step|
              Etl::Refresh::Yahoo.new(logger).daily_one_stock(stock)
              yield stock, step.percent
            end

            steps.step(weight: 1) do |step|
              Etl::Refresh::Dividend.new(logger).weekly_one_stock(stock)
              yield stock, step.percent
            end

            steps.step(weight: 4) do |step|
              Etl::Refresh::Iexapis.new(logger).weekly_one_stock(stock, immediate: true)
              yield stock, step.percent
            end
          end
        end
      end
    end
  end
end

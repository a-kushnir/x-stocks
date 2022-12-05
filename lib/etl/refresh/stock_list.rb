# frozen_string_literal: true

module Etl
  module Refresh
    # Extracts and transforms data for stock list
    class StockList
      def update(stocks, logger)
        progress_bar = ProgressBar.new
        progress_bar.loop_with_index(stocks) do |node, index|
          stock = node.object
          yield stock, node.percent, index

          node.steps do |steps|
            steps.step(weight: 3) do |step|
              Etl::Refresh::Finnhub.new(logger).daily_one_stock(stock)
              yield stock, step.percent, index
            end

            steps.step(weight: 2) do |step|
              Etl::Refresh::Yahoo.new(logger).daily_one_stock(stock)
              yield stock, step.percent, index
            end

            steps.step(weight: 1) do |step|
              Etl::Refresh::Dividend.new(logger).weekly_one_stock(stock)
              yield stock, step.percent, index
            end
          end
        end
      end
    end
  end
end

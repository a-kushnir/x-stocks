# frozen_string_literal: true

module Etl
  module Transform
    # Transforms data extracted from www.slickcharts.com
    class SlickCharts
      def initialize(stock_class: Stock)
        @stock_class = stock_class
      end

      def sp500(symbols)
        update(symbols, :sp500) unless symbols.blank?
      end

      def nasdaq100(symbols)
        update(symbols, :nasdaq100) unless symbols.blank?
      end

      def dow_jones(symbols)
        update(symbols, :dowjones) unless symbols.blank?
      end

      private

      def update(symbols, column)
        stock_ids = stock_class.where(symbol: symbols).pluck(:id)
        stock_class.where(id: stock_ids).update_all(column => true)
        stock_class.where.not(id: stock_ids).update_all(column => false)
      end

      attr_reader :stock_class
    end
  end
end

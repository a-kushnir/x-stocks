# frozen_string_literal: true

module Etl
  module Transform
    # Transforms data extracted from www.slickcharts.com
    class SlickCharts
      def sp500(list)
        return if list.blank?

        stock_ids = Stock.unscoped.where(symbol: list).pluck(:id)
        Stock.unscoped.where(id: stock_ids).update_all(sp500: true)
        Stock.unscoped.where.not(id: stock_ids).update_all(sp500: false)
      end

      def nasdaq100(list)
        return if list.blank?

        stock_ids = Stock.unscoped.where(symbol: list).pluck(:id)
        Stock.unscoped.where(id: stock_ids).update_all(nasdaq100: true)
        Stock.unscoped.where.not(id: stock_ids).update_all(nasdaq100: false)
      end

      def dow_jones(list)
        return if list.blank?

        stock_ids = Stock.unscoped.where(symbol: list).pluck(:id)
        Stock.unscoped.where(id: stock_ids).update_all(dowjones: true)
        Stock.unscoped.where.not(id: stock_ids).update_all(dowjones: false)
      end
    end
  end
end
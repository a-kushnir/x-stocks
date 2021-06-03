# frozen_string_literal: true

module XStocks
  module Jobs
    # PolygonStockAll Job
    class PolygonStockAll < Base
      def name
        'Update stock information'
      end

      def tags
        ['Polygon']
      end

      def perform(&block)
        lock do |logger|
          Etl::Refresh::Polygon.new(logger).weekly_all_stocks(&block)
        end
      end
    end
  end
end

# frozen_string_literal: true

module DataTable
  module Formats
    # Formats value as a stock link
    class StockLink < Link
      def format(value)
        super([value, main_app.stock_path(value)]) if value
      end

      private

      def main_app
        Rails.application.routes.url_helpers
      end
    end
  end
end
